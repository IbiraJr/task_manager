import 'package:task_manager/features/task/domain/entities/task.dart';

import '../repositories/task_repository.dart';

class GetTasks {
  final TaskRepository taskRepository;

  GetTasks({required this.taskRepository});

  Future<List<Task>> call() async {
    return await taskRepository.getTasks();
  }
}
