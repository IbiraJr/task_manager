import 'package:task_manager/features/task/domain/entities/task.dart';

class TaskModel extends Task {
  final bool isSynced;
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.createdAt,
    required this.isSynced,
  });
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    isCompleted: json['completed'] == 1,
    createdAt: DateTime.parse(json['created_at']),
    isSynced: json['is_synced'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'is_completed': isCompleted ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
  };
}
