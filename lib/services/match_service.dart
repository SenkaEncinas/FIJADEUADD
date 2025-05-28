import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uadd_app/models/Match/match_detail_dto.dart';
import 'package:uadd_app/models/Match/match_dto.dart';
import '../models/match/match_create_dto.dart';

class MatchService {
  final String _baseUrl = 'https://app-250528131912.azurewebsites.net/api/matches';

  Future<List<MatchDto>> getAllMatchs() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => MatchDto.fromJson(json)).toList();
    }

    throw Exception('Error al cargar partidos');
  }

  Future<MatchDetailDto> getMatchById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return MatchDetailDto.fromJson(jsonDecode(response.body));
    }

    throw Exception('Publicación no encontrada');
  }

  Future<bool> createMatch(MatchCreateDto dto) async {
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

  Future<bool> updateMatch(int id, MatchCreateDto dto) async {
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

  Future<bool> deleteMatch(int id) async {
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
