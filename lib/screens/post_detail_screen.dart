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
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
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
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: Colors.green[800],
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Producto',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20)),
          centerTitle: true,
          backgroundColor: theme.primaryColor,
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshPost,
              tooltip: 'Actualizar',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshPost,
          color: theme.primaryColor,
          child: FutureBuilder<NewsPostDetailDto>(
            future: _futurePost,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: theme.primaryColor),
                      const SizedBox(height: 16),
                      Text('Error al cargar la publicación',
                          style: TextStyle(
                              fontSize: 16, color: theme.primaryColor)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _refreshPost,
                        child: const Text('Reintentar',
                            style: TextStyle(color: Colors.white)),
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
                    // Imagen principal con decoración
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            Image.network(
                              post.imageUrl,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: theme.primaryColor),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '\$${post.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título y información principal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (post.category != null && post.category!.isNotEmpty)
                            _buildCategoryChip(post.category!),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 18, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Publicado el ${post.publishDate.day}/${post.publishDate.month}/${post.publishDate.year}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Información básica
                    _buildInfoCard('Información del Producto', [
                      if (post.category != null && post.category!.isNotEmpty)
                        _buildInfoRow(Icons.category, 'Categoría', post.category!),
                      _buildInfoRow(Icons.location_on, 'Ubicación', post.location),
                      _buildInfoRow(Icons.assessment, 'Condición', post.condition),
                      _buildInfoRow(
                          Icons.payment, 'Método de pago', post.paymentMethod),
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

                    // Botón de contacto
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Acción de contacto
                          },
                          child: const Text(
                            'CONTACTAR AL VENDEDOR',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}