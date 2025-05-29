import 'package:dartz/dartz.dart' as dartz;
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/repositories/task_repository.dart';

class AddTask {
  final TaskRepository taskRepository;

  AddTask({required this.taskRepository});

  Future<dartz.Either<Failure, void>> call(Task task) async {
    return await taskRepository.addTask(task);
  }
}
