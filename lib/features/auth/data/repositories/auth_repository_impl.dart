import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});
  @override
  Future<Either<Failure, User>> signIn(String email, String password) async {
    try {
      final UserModel userModel = await authRemoteDataSource.signIn(
        email,
        password,
      );
      return Right(
        User(id: userModel.id, email: userModel.email, name: userModel.name),
      );
    } on auth.FirebaseAuthException catch (e) {
      return Left(mapFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure('Unknown error: ${e.toString()}'));
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserModel userModel = await authRemoteDataSource.signUp(
        email,
        password,
        name,
      );
      return Right(
        User(id: userModel.id, email: userModel.email, name: userModel.name),
      );
    } on auth.FirebaseAuthException catch (e) {
      return Left(mapFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure('Unknown error: ${e.toString()}'));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    return authRemoteDataSource.getCurrentUser();
  }
}
