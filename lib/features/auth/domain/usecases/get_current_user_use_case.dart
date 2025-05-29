import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository authRepository;
  GetCurrentUserUseCase(this.authRepository);
  User? call() {
    return authRepository.getCurrentUser();
  }
}
