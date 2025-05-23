import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository authRepository;

  SignOutUseCase(this.authRepository);
  Future<void> call() async {}
}
