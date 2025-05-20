part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  SignInEvent({required this.email, required this.password});
}
