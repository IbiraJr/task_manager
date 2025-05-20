import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository authRepository;
  SignUpUseCase(this.authRepository);
}
