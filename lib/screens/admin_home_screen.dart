import 'package:flutter/material.dart';
import '../models/news_post/news_post_dto.dart';
import '../services/post_service.dart';
import 'login_screen.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _postService = PostService();
  late Future<List<NewsPostDto>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _futurePosts = _postService.getAllPosts();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostFormScreen()),
    );
    if (!mounted) return;
    if (result is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      _loadPosts();
      setState(() {});
    }
  }

  void _goToEdit(NewsPostDto post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostFormScreen(editPost: post)),
    );
    if (!mounted) return;
    if (result is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      _loadPosts();
      setState(() {});
    }
  }


  void _deletePost(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar publicación?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _postService.deletePost(id);
      if (success) {
        _loadPosts();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar publicación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Publicaciones'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          IconButton(onPressed: _goToCreate, icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder<List<NewsPostDto>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error al cargar publicaciones'));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(post.title),
                subtitle: Text('${post.location} - \$${post.price}'),
                leading: Image.network(post.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(postId: post.id),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _goToEdit(post);
                    } else if (value == 'delete') {
                      _deletePost(post.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
