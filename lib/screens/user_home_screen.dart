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
      'Electronica',
      'Ropa',
      'Hogar',
      'Deportes',
      'Juguetes',
      'Libros',
      'Comida',
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
      final theme = Theme.of(context).copyWith(
        primaryColor: const Color(0xFF2E7D32), // Verde principal
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2E7D32),
              secondary: const Color(0xFF81C784), // Verde claro
            ),
      );

      return Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Publicaciones',
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
                onPressed: _refreshPosts,
                tooltip: 'Actualizar',
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Cerrar sesión',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshPosts,
            color: theme.primaryColor,
            child: FutureBuilder<List<NewsPostDto>>(
              future: _futurePosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: theme.primaryColor),
                        const SizedBox(height: 16),
                        Text('Error al cargar publicaciones',
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
                          onPressed: _refreshPosts,
                          child: const Text('Reintentar',
                              style: TextStyle(color: Colors.white)),
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
                        Icon(Icons.info_outline,
                            size: 48, color: theme.primaryColor),
                        const SizedBox(height: 16),
                        Text('No hay publicaciones disponibles',
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
                          onPressed: _refreshPosts,
                          child: const Text('Actualizar',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Filtros de búsqueda con estilo verde
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar publicaciones...',
                              prefixIcon: Icon(Icons.search,
                                  color: theme.primaryColor),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: theme.primaryColor, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: theme.primaryColor, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: theme.primaryColor, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  dropdownColor: Colors.white,
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: theme.primaryColor),
                                  items: _categories.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(
                                              color: theme.primaryColor)),
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
                                    labelStyle:
                                        TextStyle(color: theme.primaryColor),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: theme.primaryColor, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: theme.primaryColor, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: theme.primaryColor, width: 1),
                                ),
                                child: Text(
                                  '\$${_maxPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
  data: SliderTheme.of(context).copyWith(
    activeTrackColor: theme.primaryColor,
    inactiveTrackColor: theme.primaryColor.withOpacity(0.3),
    thumbColor: theme.primaryColor,
    overlayColor: theme.primaryColor.withOpacity(0.2),
    valueIndicatorColor: theme.primaryColor,
    activeTickMarkColor: Colors.white,
    inactiveTickMarkColor: Colors.transparent,
    trackHeight: 3.0, // Altura de la línea del slider (más delgada)
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 8.0, // Tamaño del círculo deslizante
      disabledThumbRadius: 8.0,
      elevation: 0,
      pressedElevation: 0,
    ),
    overlayShape: const RoundSliderOverlayShape(
      overlayRadius: 12.0, // Área de toque alrededor del thumb
    ),
    trackShape: const RectangularSliderTrackShape(), // Forma rectangular simple
    valueIndicatorShape: const PaddleSliderValueIndicatorShape(), // Forma del tooltip
  ),
  child: Container(
    constraints: const BoxConstraints(
      maxHeight: 24.0, // Limita la altura máxima del contenedor
    ),
    child: Slider(
      value: _maxPrice,
      min: 0,
      max: allPosts
          .map((p) => p.price)
          .reduce((a, b) => a > b ? a : b),
      divisions: 20,
      label: _maxPrice.toStringAsFixed(2),
      onChanged: (value) {
        setState(() {
          _maxPrice = value;
          _filterPosts();
        });
      },
    ),
  ),
),
                        ],
                      ),
                    ),

                    // Lista de publicaciones con estilo mejorado
                    Expanded(
                      child: _filteredPosts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 48, color: theme.primaryColor),
                                  const SizedBox(height: 16),
                                  Text('No se encontraron resultados',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: theme.primaryColor)),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _selectedCategory = 'Todas';
                                        _maxPrice = allPosts
                                            .map((p) => p.price)
                                            .reduce((a, b) => a > b ? a : b);
                                        _filterPosts();
                                      });
                                    },
                                    child: const Text('Limpiar filtros',
                                        style: TextStyle(color: Colors.white)),
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
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PostDetailScreen(postId: post.id),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Imagen con decoración
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(15)),
                                          child: Stack(
                                            children: [
                                              Image.network(
                                                post.imageUrl,
                                                height: 180,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  height: 180,
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child: Icon(Icons.broken_image,
                                                        size: 50,
                                                        color: theme.primaryColor),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: theme.primaryColor
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '\$${post.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Contenido de la tarjeta
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Título
                                              Text(
                                                post.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),

                                              // Categoría y ubicación
                                              Row(
                                                children: [
                                                  if (post.category != null &&
                                                      post.category!.isNotEmpty)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: theme.primaryColor
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                12),
                                                        border: Border.all(
                                                          color: theme.primaryColor
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        post.category!,
                                                        style: TextStyle(
                                                          color:
                                                              theme.primaryColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  const Spacer(),
                                                  Icon(Icons.location_on,
                                                      size: 16,
                                                      color: theme.primaryColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    post.location,
                                                    style: TextStyle(
                                                      color: theme.primaryColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Fecha y botón
                                              Row(
                                                children: [
                                                  Text(
                                                    'Publicado el ${post.publishDate.day}/${post.publishDate.month}/${post.publishDate.year}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: theme.primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: const Text(
                                                      'Ver más',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ],
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
        ),
      );
    }
  }