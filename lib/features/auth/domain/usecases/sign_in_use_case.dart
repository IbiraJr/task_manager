import 'package:dartz/dartz.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository authRepository;
  SignInUseCase(this.authRepository);
  Future<Either<Failure, User>> call(String email, String password) {
    return authRepository.signIn(email, password);
  }
}
