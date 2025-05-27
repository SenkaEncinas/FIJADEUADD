import 'package:flutter/material.dart';
import '../models/news_post/news_post_detail_dto.dart';
import '../services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _postService = PostService();
  late Future<NewsPostDetailDto> _futurePost;

  @override
  void initState() {
    super.initState();
    _refreshPost();
  }

  Future<void> _refreshPost() async {
    setState(() {
      _futurePost = _postService.getPostById(widget.postId);
    });
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Chip(
      label: Text(
        category,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Producto'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPost,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPost,
        child: FutureBuilder<NewsPostDetailDto>(
          future: _futurePost,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Error al cargar la publicación'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshPost,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final post = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen principal
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título, categoría y precio
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '\$${post.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (post.category != null && post.category!.isNotEmpty)
                        _buildCategoryChip(post.category!),
                      const SizedBox(height: 8),
                      Text(
                        'Publicado el ${post.publishDate.day}/${post.publishDate.month}/${post.publishDate.year}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Información básica (ahora incluye categoría)
                  _buildInfoCard('Información del Producto', [
                    if (post.category != null && post.category!.isNotEmpty)
                      _buildInfoRow(Icons.category, 'Categoría', post.category!),
                    _buildInfoRow(Icons.location_on, 'Ubicación', post.location),
                    _buildInfoRow(Icons.assessment, 'Condición', post.condition),
                    _buildInfoRow(Icons.payment, 'Método de pago', post.paymentMethod),
                  ]),

                  // Descripción
                  _buildInfoCard('Descripción', [
                    Text(
                      post.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ]),

                  // Contacto
                  _buildInfoCard('Información de Contacto', [
                    _buildInfoRow(Icons.email, 'Email', post.email),
                    if (post.phoneNumber.isNotEmpty)
                      _buildInfoRow(Icons.phone, 'Teléfono', post.phoneNumber),
                    if (post.whatsAppLink.isNotEmpty)
                      _buildInfoRow(Icons.chat, 'WhatsApp', post.whatsAppLink),
                  ]),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}