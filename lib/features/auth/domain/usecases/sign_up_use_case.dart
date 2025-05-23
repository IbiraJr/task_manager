import 'package:dartz/dartz.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository authRepository;
  SignUpUseCase(this.authRepository);
  Future<Either<Failure, User>> call(
    String email,
    String password,
    String name,
  ) {
    return authRepository.signUp(email, password, name);
  }
}
