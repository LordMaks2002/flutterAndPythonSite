// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/todo_list_screen.dart';

void main() async {
  // ІНІЦІАЛІЗАЦІЯ HIVE ДЛЯ WEB
  await Hive.initFlutter();
  await Hive.openBox('todos'); // локальна "база"

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO Web',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
