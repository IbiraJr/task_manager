import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/repositories/task_repository.dart';

class AddTask {
  final TaskRepository taskRepository;

  AddTask({required this.taskRepository});

  Future<void> call(Task task) async {
    return await taskRepository.addTask(task);
  }
}
