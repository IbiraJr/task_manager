import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> initializeAuthInjectionContainer(GetIt sl) async {
  //Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  //Bloc
  sl.registerLazySingleton(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );
}
