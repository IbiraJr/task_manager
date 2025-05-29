import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  UserModel? getCurrentUser();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});
  @override
  Future<UserModel> signIn(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) {
      throw UnknownAuthException();
    }
    return UserModel(
      id: userCredential.user!.uid,
      email: userCredential.user!.email!,
      name: userCredential.user!.displayName!,
    );
  }

  @override
  Future<void> signOut() {
    return firebaseAuth.signOut();
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user!.updateDisplayName(name);
    final updatedUser = firebaseAuth.currentUser!;
    return UserModel(
      id: updatedUser.uid,
      email: updatedUser.email!,
      name: updatedUser.displayName!,
    );
  }

  @override
  UserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
      );
    }
    return null;
  }
}
