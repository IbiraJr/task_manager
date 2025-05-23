import 'package:firebase_auth/firebase_auth.dart';
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
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user!.updateDisplayName(name);
    final updatedUser = await firebaseAuth.currentUser!;
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
