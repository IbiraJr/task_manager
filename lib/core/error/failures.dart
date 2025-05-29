import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Failure  extends Equatable {
  final String message;
  Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}

Failure mapFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'wrong-password':
      return AuthFailure('Email or password is incorrect.');
    case 'user-not-found':
      return AuthFailure('User not found.');
    case 'email-already-in-use':
      return AuthFailure('The account already exists for that email.');
    case 'weak-password':
      return AuthFailure('The password provided is too weak.');
    case 'invalid-email':
      return AuthFailure('The email address is invalid.');
    case 'user-disabled':
      return AuthFailure(
        'The user corresponding to this email has been disabled.',
      );
    case 'too-many-requests':
      return AuthFailure('Too many requests, please try again later.');
    case 'user-token-expired':
      return AuthFailure(
        'The user is no longer authenticated since his refresh token has been expired.',
      );
    case 'network-request-failed':
      return AuthFailure('Network request failed.');
    case 'invalid-credential' || 'invalid-login-credentials':
      return AuthFailure('Invalid login credentials.');
    case 'operation-not-allowed':
      return AuthFailure('Operation not allowed.');
    default:
      return AuthFailure('Authentication failed. ${e.message}');
  }
}
