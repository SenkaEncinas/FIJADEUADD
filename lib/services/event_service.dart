import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uadd_app/models/Event/event_dto.dart';
import '../models/event/event_detail_dto.dart';
import '../models/event/event_create_dto.dart';

class EventService {
  final String _baseUrl = 'https://app-250528131912.azurewebsites.net/api/event';

  Future<List<EventDto>> getAllEvents() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => EventDto.fromJson(json)).toList();
    }

    throw Exception('Error al cargar eventos');
  }

  Future<EventDetailDto> getEventById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return EventDetailDto.fromJson(jsonDecode(response.body));
    }

    throw Exception('Evento no encontrado');
  }

  Future<bool> createEvent(EventCreateDto dto) async {
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

  Future<bool> updateEvent(int id, EventCreateDto dto) async {
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

  Future<bool> deleteEvent(int id) async {
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