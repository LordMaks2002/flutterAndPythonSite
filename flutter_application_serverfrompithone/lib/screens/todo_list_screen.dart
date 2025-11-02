// lib/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../models/todo.dart';
import 'package:uuid/uuid.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final SyncService sync = SyncService();
  final TextEditingController _controller = TextEditingController();
  List<Todo> todos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Завантаження з локальної БД...');
      final loaded = await sync.local.getAll();
      print('Завантажено локально: ${loaded.length} задач');

      setState(() {
        todos = loaded;
        _isLoading = false;
      });

      // Синхронізація з бекендом
      print('Спроба синхронізації...');
      await sync.syncIfPossible();
      final updated = await sync.local.getAll();
      print('Після синхронізації: ${updated.length} задач');

      setState(() {
        todos = updated;
      });
    } catch (e, stack) {
      print('ПОМИЛКА ЗАВАНТАЖЕННЯ: $e');
      print(stack);
      setState(() {
        _error = 'Помилка: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTodo() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final tempId = Uuid().v4();
    final now = DateTime.now();
    final newTodo = Todo(
      id: tempId,
      title: title,
      completed: false,
      updatedAt: now,
      localId: 0,
    );

    setState(() {
      todos.insert(0, newTodo);
      _controller.clear();
    });

    try {
      await sync.create(newTodo);
      await _loadTodos(); // оновлюємо з БД
    } catch (e) {
      print('Помилка додавання: $e');
      _showSnackBar('Не вдалося додати');
    }
  }

  Future<void> _toggle(Todo todo) async {
    final updated = todo.copyWith(completed: !todo.completed);
    setState(() {
      final i = todos.indexWhere((t) => t.id == todo.id);
      if (i != -1) todos[i] = updated;
    });
    await sync.update(updated);
  }

  Future<void> _delete(String id) async {
    setState(() {
      todos.removeWhere((t) => t.id == id);
    });
    await sync.delete(id);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO Sync'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: _loadTodos,
            tooltip: 'Оновити',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: _loadTodos,
                      child: Text('Спробувати знову'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // === Поле вводу ===
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Нова задача...',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addTodo(),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addTodo,
                          child: Icon(Icons.add),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === Список ===
                  Expanded(
                    child:
                        todos.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Немає задач',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'Додай першу!',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: todos.length,
                              itemBuilder: (context, i) {
                                final todo = todos[i];
                                return Dismissible(
                                  key: Key(todo.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) => _delete(todo.id),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: todo.completed,
                                      onChanged: (_) => _toggle(todo),
                                    ),
                                    title: Text(
                                      todo.title,
                                      style: TextStyle(
                                        decoration:
                                            todo.completed
                                                ? TextDecoration.lineThrough
                                                : null,
                                        color:
                                            todo.completed ? Colors.grey : null,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _delete(todo.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
