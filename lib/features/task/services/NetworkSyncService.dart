import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:task_manager/features/task/domain/repositories/task_repository.dart';

class NetworkSyncService {
  final TaskRepository taskRepository;
  late final StreamSubscription _subscription;

  NetworkSyncService({required this.taskRepository});

  void initialize() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      if (!result.contains(ConnectivityResult.none)) {
        await taskRepository.syncPendingTasks();
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
