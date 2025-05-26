import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/news_post/news_post_create_dto.dart';
import '../models/news_post/news_post_dto.dart';
import '../services/post_service.dart';

class PostFormScreen extends StatefulWidget {
  final NewsPostDto? editPost;

  const PostFormScreen({super.key, this.editPost});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _postService = PostService();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _conditionController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _imageUrlController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editPost != null) {
      _titleController.text = widget.editPost!.title;
      _priceController.text = widget.editPost!.price.toString();
      _locationController.text = widget.editPost!.location;
      _imageUrlController.text = widget.editPost!.imageUrl;
      _uploadedImageUrl = widget.editPost!.imageUrl;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes subir una imagen')),
      );
      return;
    }

    setState(() => _loading = true);

    final dto = NewsPostCreateDto(
      title: _titleController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      location: _locationController.text,
      condition: _conditionController.text,
      paymentMethod: _paymentMethodController.text,
      description: _descriptionController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      whatsAppLink: _whatsappController.text,
      imageUrl: _imageUrlController.text,
    );

    bool success;
    if (widget.editPost != null) {
      success = await _postService.updatePost(widget.editPost!.id, dto);
    } else {
      success = await _postService.createPost(dto);
    }

    if (!mounted) return;
    if (success) {
      final message = widget.editPost != null
        ? '¡Publicación actualizada con éxito!'
        : '¡Publicación guardada con éxito!';
      Navigator.pop(context, message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar')),
      );
    }

    setState(() => _loading = false);
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
    });

    final uri = Uri.parse('https://app-250518155355.azurewebsites.net/api/upload');
    final request = http.MultipartRequest('POST', uri);

    final token = await _getToken();
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('file', picked.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final imageUrl = RegExp(r'"imageUrl"\s*:\s*"([^"]+)"').firstMatch(responseBody)?.group(1);
      setState(() {
        _uploadedImageUrl = imageUrl;
        _imageUrlController.text = imageUrl ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir imagen')),
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editPost != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar publicación' : 'Nueva publicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título'), validator: _required),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number, validator: _required),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Ubicación'), validator: _required),
              TextFormField(controller: _conditionController, decoration: const InputDecoration(labelText: 'Condición'), validator: _required),
              TextFormField(controller: _paymentMethodController, decoration: const InputDecoration(labelText: 'Método de pago'), validator: _required),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3, validator: _required),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Teléfono'), validator: _required),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: _required),
              TextFormField(controller: _whatsappController, decoration: const InputDecoration(labelText: 'Link de WhatsApp'), validator: _required),
              TextFormField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'URL de imagen'), validator: _required),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _pickAndUploadImage,
                icon: const Icon(Icons.image),
                label: const Text('Subir imagen'),
              ),

              if (_uploadedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.network(_uploadedImageUrl!, height: 150),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: Text(_loading
                    ? 'Guardando...'
                    : isEdit ? 'Actualizar' : 'Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return (value == null || value.isEmpty) ? 'Campo obligatorio' : null;
  }
}
