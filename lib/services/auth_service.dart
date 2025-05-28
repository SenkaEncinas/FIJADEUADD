import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user/token_dto.dart';
import '../models/user/user_info_dto.dart';
import '../models/user/user_login_dto.dart';
import '../models/user/user_register_dto.dart';

class AuthService {
  final String _baseUrl = 'https://app-250528131912.azurewebsites.net/api/auth';

  Future<bool> register(UserRegisterDto dto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final token = TokenDto.fromJson(jsonDecode(response.body)).token;
      await _saveToken(token);
      return true;
    }
    return false;
  }

  Future<bool> login(UserLoginDto dto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final token = TokenDto.fromJson(jsonDecode(response.body)).token;
      await _saveToken(token);
      return true;
    }
    return false;
  }

  Future<UserInfoDto?> getCurrentUser() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return UserInfoDto.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
