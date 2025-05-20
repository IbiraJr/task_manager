abstract class AuthRemoteDataSource {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String name);
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> signIn(String email, String password) {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<void> signUp(String email, String password, String name) {
    // TODO: implement signUp
    throw UnimplementedError();
  }
}
