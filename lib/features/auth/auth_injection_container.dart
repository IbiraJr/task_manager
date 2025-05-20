import 'package:get_it/get_it.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager/features/task/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/features/task/data/repositories/task_repository_impl.dart';
import 'package:task_manager/features/task/domain/repositories/task_repository.dart';

Future<void> initializeAuthInjectionContainer(GetIt sl) async {
  //Core

  //Services
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
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));

  //Bloc
  sl.registerFactory(() => AuthBloc(signInUseCase: sl(), signUpUseCase: sl()));
}
