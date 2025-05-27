import 'package:flutter/material.dart';
import '../models/news_post/news_post_dto.dart';
import '../services/post_service.dart';
import 'post_detail_screen.dart';
import 'login_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _postService = PostService();
  late Future<List<NewsPostDto>> _futurePosts;
  List<NewsPostDto> _filteredPosts = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  double _maxPrice = 10000;
  final List<String> _categories = [
    'Todas',
    'Electrónica',
    'Ropa',
    'Hogar',
    'Deportes',
    'Juguetes',
    'Libros',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _refreshPosts();
    _searchController.addListener(_filterPosts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _futurePosts = _postService.getAllPosts();
    });
    _futurePosts.then((posts) {
      setState(() {
        _filteredPosts = posts;
        if (posts.isNotEmpty) {
          _maxPrice = posts.map((p) => p.price).reduce((a, b) => a > b ? a : b);
        }
      });
    });
  }

  void _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _filterPosts() {
    if (_futurePosts == null) return;

    _futurePosts.then((posts) {
      setState(() {
        _filteredPosts = posts.where((post) {
          final matchesSearch = post.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
          final matchesCategory = _selectedCategory == 'Todas' || 
              (post.category != null && post.category == _selectedCategory);
          final matchesPrice = post.price <= _maxPrice;
          return matchesSearch && matchesCategory && matchesPrice;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPosts,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<NewsPostDto>>(
          future: _futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Error al cargar publicaciones',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshPosts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final allPosts = snapshot.data!;
            if (allPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('No hay publicaciones disponibles',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshPosts,
                      child: const Text('Actualizar'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Filtros de búsqueda (se mantienen igual)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar publicaciones...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                            _filterPosts();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precio máximo: \$${_maxPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Slider(
                            value: _maxPrice,
                            min: 0,
                            max: allPosts.map((p) => p.price).reduce((a, b) => a > b ? a : b),
                            divisions: 20,
                            label: _maxPrice.toStringAsFixed(2),
                            onChanged: (value) {
                              setState(() {
                                _maxPrice = value;
                                _filterPosts();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Lista de publicaciones con nuevo estilo
                Expanded(
                  child: _filteredPosts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('No se encontraron resultados',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedCategory = 'Todas';
                                    _maxPrice = allPosts.map((p) => p.price).reduce((a, b) => a > b ? a : b);
                                    _filterPosts();
                                  });
                                },
                                child: const Text('Limpiar filtros'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = _filteredPosts[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailScreen(postId: post.id),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Imagen en la parte superior
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                      child: Image.network(
                                        post.imageUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                          height: 180,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.broken_image, size: 50),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Información debajo de la imagen
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Título con estilo similar al banner
                                          Text(
                                            post.title.toUpperCase(),
                                            style: textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Precio y categoría
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '\$${post.price.toStringAsFixed(2)}',
                                                style: textTheme.titleMedium?.copyWith(
                                                  color: theme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (post.category != null && post.category!.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: theme.primaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    post.category!,
                                                    style: TextStyle(
                                                      color: theme.primaryColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Ubicación con icono
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                post.location,
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Fecha de publicación
                                          const SizedBox(height: 8),
                                          Text(
                                            'Publicado el ${post.publishDate.day}/${post.publishDate.month}/${post.publishDate.year}',
                                            style: textTheme.bodySmall?.copyWith(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}