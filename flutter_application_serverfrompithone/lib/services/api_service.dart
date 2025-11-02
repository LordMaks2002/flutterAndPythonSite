// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  // lib/services/api_service.dart
  final String baseUrl = 'http://127.0.0.1:5000'; // для Web

  Future<List<Todo>> getTodos() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/todos'))
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List json = jsonDecode(response.body);
        return json.map((e) {
          return Todo.fromJson({
            ...e,
            'updatedAt': e['updatedAt'] ?? DateTime.now().toIso8601String(),
            'localId': 0,
          });
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Todo?> createTodo(String title) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );
      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return Todo.fromJson({
          ...json,
          'updatedAt': json['updatedAt'] ?? DateTime.now().toIso8601String(),
          'localId': 0,
        });
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateTodo(String id, bool completed) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'completed': completed}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTodo(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
