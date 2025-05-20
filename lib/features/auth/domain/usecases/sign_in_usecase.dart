import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository authRepository;
  SignInUseCase(this.authRepository);
}
