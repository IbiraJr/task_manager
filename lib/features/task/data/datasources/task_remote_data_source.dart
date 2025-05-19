import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/task/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<void> addTask(TaskModel task);
  Future<List<TaskModel>> syncTasks();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  TaskRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addTask(TaskModel task) async {
    await firestore.collection('tasks').add(task.toJson());
  }

  @override
  Future<List<TaskModel>> syncTasks() {
    return firestore
        .collection('tasks')
        .get()
        .then(
          (value) =>
              value.docs.map((e) => TaskModel.fromJson(e.data())).toList(),
        );
  }
}
