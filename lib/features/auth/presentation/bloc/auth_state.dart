part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class Unauthenticated extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {}

final class AuthError extends AuthState {
  final Failure failure;
  AuthError(this.failure);
}
