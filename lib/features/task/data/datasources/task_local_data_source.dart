import 'package:sqflite/sqflite.dart';
import 'package:task_manager/core/database/local_database.dart';
import 'package:task_manager/features/task/data/models/task_model.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';

abstract class TaskLocalDataSource {
  Future<List<Task>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<List<TaskModel>> getUnsyncedTasks();
  Future<void> markTaskAsSynced(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final DatabaseHelper databaseHelper;

  TaskLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<Task>> getTasks() async {
    final db = await databaseHelper.db;
    final maps = await db.query('tasks');
    return maps.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    final db = await databaseHelper.db;
    await db.insert(
      'tasks',
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final db = await databaseHelper.db;
    await db.delete('tasks');
    for (var task in tasks) {
      await db.insert('tasks', task.toJson());
    }
  }

  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await databaseHelper.db;
    final result = await db.query(
      'tasks',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  Future<void> markTaskAsSynced(String id) async {
    final db = await databaseHelper.db;
    await db.update(
      'tasks',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
