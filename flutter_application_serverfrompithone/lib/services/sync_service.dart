// lib/services/sync_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_db_service.dart';
import 'api_service.dart';
import '../models/todo.dart';

class SyncService {
  final LocalDbService local = LocalDbService();
  final ApiService remote = ApiService();

  Future<bool> get _hasInternet async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncIfPossible() async {
    if (!await _hasInternet) return;

    try {
      final remoteTodos = await remote.getTodos();
      await local.clear();
      for (final todo in remoteTodos) {
        await local.insert(todo);
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  Future<void> create(Todo todo) async {
    await local.insert(todo);
    if (await _hasInternet) {
      final serverTodo = await remote.createTodo(todo.title);
      if (serverTodo != null) {
        await local.delete(todo.id);
        await local.insert(serverTodo);
      }
    }
  }

  Future<void> update(Todo todo) async {
    await local.updateTodo(todo);
    if (await _hasInternet) {
      await remote.updateTodo(todo.id, todo.completed);
    }
  }

  Future<void> delete(String id) async {
    await local.delete(id);
    if (await _hasInternet) {
      await remote.deleteTodo(id);
    }
  }
}
