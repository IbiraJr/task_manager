import 'package:firebase_auth/firebase_auth.dart';

abstract class Failure {
  final String message;
  Failure(this.message);
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
    default:
      return AuthFailure('Authentication failed. ${e.message}');
  }
}
