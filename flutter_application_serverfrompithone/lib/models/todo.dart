// lib/models/todo.dart
class Todo {
  final String id; // UUID з бекенду або тимчасовий
  final String title;
  bool completed;
  final DateTime updatedAt;
  final int localId; // SQLite ID

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
    required this.updatedAt,
    this.localId = 0,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      completed: json['completed'] == 1 || json['completed'] == true,
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      localId: json['localId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed ? 1 : 0,
      'updatedAt': updatedAt.toIso8601String(),
      'localId': localId,
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? updatedAt,
    int? localId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      localId: localId ?? this.localId,
    );
  }

  @override
  String toString() => 'Todo(id: $id, title: $title, completed: $completed)';
}
