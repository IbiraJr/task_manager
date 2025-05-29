part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {}

final class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  SignInEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

final class SignOutEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class CheckAuthStatusEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}
