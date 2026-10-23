import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Task {
  int? id;
  String? title;
  String? description;
  String? date;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.isCompleted,
  });

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'isCompleted': isCompleted,
    };
  }
}

class DBHelper {
  Database? db;

  Future openDB() async {
    if (db != null) return db;
    db = await openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, date TEXT, isCompleted BOOLEAN)',
        );
      },
      version: 1,
    );
    return db;
  }

  Future<void> insert(Task task) async {
    final db = await openDB();
    await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> read() async {
    final db = await openDB();
    final List<Map<String, Object?>> taskMaps = await db.query('tasks');
    return [
      for (final {
            'id': id as int,
            'title': title as String,
            'description': description as String,
            'date': date as String,
            'isCompleted': isCompleted as int,
          }
          in taskMaps)
        Task(
          id: id,
          title: title,
          description: description,
          date: date,
          isCompleted: isCompleted == 1,
        ),
    ];
  }

  Future<void> update(Task task, int id) async {
    final db = await openDB();
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await openDB();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
