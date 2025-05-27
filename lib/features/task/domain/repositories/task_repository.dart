import 'package:dartz/dartz.dart' as dartz;
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';

abstract class TaskRepository {
  Future<dartz.Either<Failure, List<Task>>> getTasks();
  Future<void> addTask(Task task);
  Future<void> syncPendingTasks();
}
