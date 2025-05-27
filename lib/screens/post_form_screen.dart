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

  // Controllers
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
  final _categoryController = TextEditingController();

  // Variables de estado
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _loading = false;
  final List<String> _categories = [
    'Electronica',
    'Ropa',
    'Hogar',
    'Deportes',
    'Juguetes',
    'Libros',
    'Otros'
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.editPost != null) {
      _titleController.text = widget.editPost!.title;
      _priceController.text = widget.editPost!.price.toString();
      _locationController.text = widget.editPost!.location;
      _imageUrlController.text = widget.editPost!.imageUrl;
      _uploadedImageUrl = widget.editPost!.imageUrl;
      _selectedCategory = widget.editPost!.category;
      _categoryController.text = widget.editPost!.category ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _conditionController.dispose();
    _paymentMethodController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

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
      imageUrl: _imageUrlController.text, // Puede estar vacío
      category: _selectedCategory ?? _categories.first,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir imagen')),
        );
      }
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
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(  
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de imagen (ahora opcional)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_uploadedImageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _uploadedImageUrl!,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadImage,
                        icon: const Icon(Icons.image),
                        label: Text(_uploadedImageUrl == null 
                            ? 'Agregar imagen (opcional)' 
                            : 'Cambiar imagen'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      if (_uploadedImageUrl != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _uploadedImageUrl = null;
                              _imageUrlController.text = '';
                            });
                          },
                          child: const Text(
                            'Eliminar imagen',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Resto del formulario (igual que antes)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Ubicación',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Selecciona una categoría' : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _conditionController,
                        decoration: const InputDecoration(
                          labelText: 'Condición',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _paymentMethodController,
                        decoration: const InputDecoration(
                          labelText: 'Método de pago',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: _required,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _whatsappController,
                        decoration: const InputDecoration(
                          labelText: 'Link de WhatsApp',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEdit ? 'ACTUALIZAR PUBLICACIÓN' : 'CREAR PUBLICACIÓN',
                        style: const TextStyle(fontSize: 16),
                      ),
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