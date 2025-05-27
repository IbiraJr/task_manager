import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';

// Generate mocks
@GenerateMocks([AuthRemoteDataSource, auth.FirebaseAuthException])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      authRemoteDataSource: mockAuthRemoteDataSource,
    );
  });

  // Test data
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tUserId = 'user123';

  const tUserModel = UserModel(id: tUserId, email: tEmail, name: tName);

  const tUser = User(id: tUserId, email: tEmail, name: tName);

  group('AuthRepositoryImpl', () {
    group('signIn', () {
      test('should return User when signIn is successful', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.signIn(any, any),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signIn(tEmail, tPassword);

        // assert
        expect(result, equals(Right(tUser)));
        verify(mockAuthRemoteDataSource.signIn(tEmail, tPassword));
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      });

      test(
        'should return AuthFailure when FirebaseAuthException occurs with invalid-email',
        () async {
          // arrange
          final firebaseException = auth.FirebaseAuthException(
            code: 'invalid-email',
            message: 'The email address is badly formatted.',
          );
          when(
            mockAuthRemoteDataSource.signIn(any, any),
          ).thenThrow(firebaseException);

          // act
          final result = await repository.signIn(tEmail, tPassword);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('email'));
          }, (_) => fail('Should return failure'));
          verify(mockAuthRemoteDataSource.signIn(tEmail, tPassword));
        },
      );

      test(
        'should return AuthFailure when FirebaseAuthException occurs with user-not-found',
        () async {
          // arrange
          final firebaseException = auth.FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found for that email.',
          );
          when(
            mockAuthRemoteDataSource.signIn(any, any),
          ).thenThrow(firebaseException);

          // act
          final result = await repository.signIn(tEmail, tPassword);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('User not found.'));
          }, (_) => fail('Should return failure'));
        },
      );

      test(
        'should return AuthFailure when FirebaseAuthException occurs with wrong-password',
        () async {
          // arrange
          final firebaseException = auth.FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password provided.',
          );
          when(
            mockAuthRemoteDataSource.signIn(any, any),
          ).thenThrow(firebaseException);

          // act
          final result = await repository.signIn(tEmail, tPassword);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Email or password is incorrect.'));
          }, (_) => fail('Should return failure'));
        },
      );

      test('should return AuthFailure when unknown exception occurs', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.signIn(any, any),
        ).thenThrow(Exception('Network error'));

        // act
        final result = await repository.signIn(tEmail, tPassword);

        // assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, contains('Unknown error'));
          expect(failure.message, contains('Network error'));
        }, (_) => fail('Should return failure'));
      });

      test('should convert UserModel to User entity correctly', () async {
        // arrange
        const customUserModel = UserModel(
          id: 'custom123',
          email: 'custom@test.com',
          name: 'Custom User',
        );
        when(
          mockAuthRemoteDataSource.signIn(any, any),
        ).thenAnswer((_) async => customUserModel);

        // act
        final result = await repository.signIn(tEmail, tPassword);

        // assert
        result.fold((_) => fail('Should return success'), (user) {
          expect(user.id, customUserModel.id);
          expect(user.email, customUserModel.email);
          expect(user.name, customUserModel.name);
          expect(user, isA<User>());
          expect(user, isNot(isA<UserModel>()));
        });
      });
    });

    group('signUp', () {
      test('should return User when signUp is successful', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.signUp(any, any, any),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signUp(tEmail, tPassword, tName);

        // assert
        expect(result, equals(Right(tUser)));
        verify(mockAuthRemoteDataSource.signUp(tEmail, tPassword, tName));
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      });

      test(
        'should return AuthFailure when FirebaseAuthException occurs with weak-password',
        () async {
          // arrange
          final firebaseException = auth.FirebaseAuthException(
            code: 'weak-password',
            message: 'The password provided is too weak.',
          );
          when(
            mockAuthRemoteDataSource.signUp(any, any, any),
          ).thenThrow(firebaseException);

          // act
          final result = await repository.signUp(tEmail, tPassword, tName);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('password'));
          }, (_) => fail('Should return failure'));
        },
      );

      test(
        'should return AuthFailure when FirebaseAuthException occurs with email-already-in-use',
        () async {
          // arrange
          final firebaseException = auth.FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'The account already exists for that email.',
          );
          when(
            mockAuthRemoteDataSource.signUp(any, any, any),
          ).thenThrow(firebaseException);

          // act
          final result = await repository.signUp(tEmail, tPassword, tName);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('email'));
          }, (_) => fail('Should return failure'));
        },
      );

      test(
        'should return AuthFailure when unknown exception occurs during signUp',
        () async {
          // arrange
          when(
            mockAuthRemoteDataSource.signUp(any, any, any),
          ).thenThrow(Exception('Server error'));

          // act
          final result = await repository.signUp(tEmail, tPassword, tName);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Unknown error'));
            expect(failure.message, contains('Server error'));
          }, (_) => fail('Should return failure'));
        },
      );

      test(
        'should convert UserModel to User entity correctly in signUp',
        () async {
          // arrange
          const customUserModel = UserModel(
            id: 'signup123',
            email: 'signup@test.com',
            name: 'Signup User',
          );
          when(
            mockAuthRemoteDataSource.signUp(any, any, any),
          ).thenAnswer((_) async => customUserModel);

          // act
          final result = await repository.signUp(tEmail, tPassword, tName);

          // assert
          result.fold((_) => fail('Should return success'), (user) {
            expect(user.id, customUserModel.id);
            expect(user.email, customUserModel.email);
            expect(user.name, customUserModel.name);
            expect(user, isA<User>());
          });
        },
      );
    });

    group('getCurrentUser', () {
      test('should return User when getCurrentUser is successful', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.getCurrentUser(),
        ).thenAnswer((_) => tUserModel);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, equals(tUser));
        verify(mockAuthRemoteDataSource.getCurrentUser());
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      });

      test('should return null when no user is logged in', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.getCurrentUser(),
        ).thenReturn(null);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, isNull);
        verify(mockAuthRemoteDataSource.getCurrentUser());
      });

      test('should propagate exception from data source', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.getCurrentUser(),
        ).thenThrow(Exception('Auth error'));

        // act & assert
        expect(() => repository.getCurrentUser(), throwsA(isA<Exception>()));
      });
    });

    group('signOut', () {
      test('should throw UnimplementedError', () {
        // act & assert
        expect(() => repository.signOut(), throwsA(isA<UnimplementedError>()));
      });
    });

    group('Edge Cases', () {
      test('should handle empty email and password in signIn', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.signIn(any, any),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signIn('', '');

        // assert
        expect(result, equals(Right(tUser)));
        verify(mockAuthRemoteDataSource.signIn('', ''));
      });

      test('should handle empty parameters in signUp', () async {
        // arrange
        when(
          mockAuthRemoteDataSource.signUp(any, any, any),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signUp('', '', '');

        // assert
        expect(result, equals(Right(tUser)));
        verify(mockAuthRemoteDataSource.signUp('', '', ''));
      });

      test(
        'should handle FirebaseAuthException with unknown error code',
        () async {
          // arrange
          final firebaseException = auth.FirebaseAuthException(
            code: 'unknown-error-code',
            message: 'Unknown Firebase error.',
          );
          when(
            mockAuthRemoteDataSource.signIn(any, any),
          ).thenThrow(firebaseException);

          // act
          final result = await repository.signIn(tEmail, tPassword);

          // assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<AuthFailure>());
            // Should still handle it via mapFirebaseAuthError function
          }, (_) => fail('Should return failure'));
        },
      );
    });
  });
}
