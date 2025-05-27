import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_post/news_post_dto.dart';
import '../models/news_post/news_post_detail_dto.dart';
import '../models/news_post/news_post_create_dto.dart';

class PostService {
  final String _baseUrl = 'https://app-250526202920.azurewebsites.net/api/newspost';

  Future<List<NewsPostDto>> getAllPosts() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => NewsPostDto.fromJson(json)).toList();
    }

    throw Exception('Error al cargar publicaciones');
  }

  Future<NewsPostDetailDto> getPostById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return NewsPostDetailDto.fromJson(jsonDecode(response.body));
    }

    throw Exception('Publicación no encontrada');
  }

  Future<bool> createPost(NewsPostCreateDto dto) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> updatePost(int id, NewsPostCreateDto dto) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 204;
  }

  Future<bool> deletePost(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 204;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
