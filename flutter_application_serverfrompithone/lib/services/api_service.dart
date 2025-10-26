import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  final String baseUrl = 'http://localhost:5000';

  Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((todo) => Todo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<Todo> createTodo(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );
    if (response.statusCode == 201) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create todo');
    }
  }

  Future<void> updateTodo(String id, bool completed) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'completed': completed}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> deleteTodo(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}
