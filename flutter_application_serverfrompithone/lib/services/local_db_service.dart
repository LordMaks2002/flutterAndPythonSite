// lib/services/local_db_service.dart
import 'package:hive/hive.dart';
import '../models/todo.dart';

class LocalDbService {
  static const String boxName = 'todos';

  Future<Box> get _box async => Hive.box(boxName);

  Future<List<Todo>> getAll() async {
    final box = await _box;
    return box.values
        .map((e) => Todo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Todo> insert(Todo todo) async {
    final box = await _box;
    final now = DateTime.now();
    final newTodo = todo.copyWith(updatedAt: now);
    await box.put(newTodo.id, newTodo.toJson());
    return newTodo;
  }

  Future<void> updateTodo(Todo todo) async {
    final box = await _box;
    final now = DateTime.now();
    await box.put(todo.id, todo.copyWith(updatedAt: now).toJson());
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}
