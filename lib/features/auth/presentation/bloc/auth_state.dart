part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class Unauthenticated extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

final class AuthError extends AuthState {
  final Failure failure;
  AuthError(this.failure);
  @override
  List<Object?> get props => [failure];
}
