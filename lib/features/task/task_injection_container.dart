import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/core/database/local_database.dart';
import 'package:task_manager/core/network/network_info.dart';
import 'package:task_manager/core/services/NetworkSyncService.dart';
import 'package:task_manager/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager/features/task/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/features/task/data/repositories/task_repository_impl.dart';
import 'package:task_manager/features/task/domain/repositories/task_repository.dart';
import 'package:task_manager/features/task/domain/usecases/add_task.dart';
import 'package:task_manager/features/task/domain/usecases/get_tasks.dart';
import 'package:task_manager/features/task/presentation/bloc/task_bloc.dart';

Future<void> initializeTaskInjectionContainer(GetIt sl) async {
  //Core
  sl.registerLazySingleton(() => DatabaseHelper.instance);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(Connectivity()));

  //Services
  sl.registerLazySingleton(() => NetworkSyncService(taskRepository: sl()));
  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      taskLocalDataSource: sl(),
      taskRemoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTasks(taskRepository: sl()));
  sl.registerLazySingleton(() => AddTask(taskRepository: sl()));

  //Bloc
  sl.registerFactory(() => TaskBloc(getTasks: sl(), addTask: sl()));
}
