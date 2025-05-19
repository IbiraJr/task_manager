import 'package:task_manager/core/network/network_info.dart';
import 'package:task_manager/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager/features/task/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/features/task/data/models/task_model.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource taskLocalDataSource;
  final TaskRemoteDataSource taskRemoteDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.taskLocalDataSource,
    required this.taskRemoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<List<Task>> getTasks() async {
    final localTasks = await taskLocalDataSource.getTasks();
    if (await networkInfo.isConnected) {
      final remoteTasks = await taskRemoteDataSource.syncTasks();
      await taskLocalDataSource.cacheTasks(remoteTasks);
      return remoteTasks;
    }
    return localTasks;
  }

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      isSynced: await networkInfo.isConnected,
    );
    if (await networkInfo.isConnected) {
      await taskRemoteDataSource.addTask(model);
    }
    await taskLocalDataSource.addTask(model);
  }

  @override
  Future<void> syncPendingTasks() async {
    final unsyncedTasks = await taskLocalDataSource.getUnsyncedTasks();
    for (var task in unsyncedTasks) {
      await taskRemoteDataSource.addTask(task);
      await taskLocalDataSource.markTaskAsSynced(task.id);
    }
  }
}
