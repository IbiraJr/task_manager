import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_use_case.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
import 'sign_up_test.mocks.dart';

void main() {
  group('SignUpUseCase', () {
    late SignUpUseCase useCase;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      useCase = SignUpUseCase(mockAuthRepository);
    });

    group('constructor', () {
      test('should initialize with AuthRepository', () {
        final repository = MockAuthRepository();
        final useCase = SignUpUseCase(repository);

        expect(useCase.authRepository, equals(repository));
      });
    });

    group('call', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testName = 'John Doe';
      const testUser = User(id: '123', email: testEmail, name: testName);

      test('should return Right(User) when sign up is successful', () async {
        // Arrange
        when(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).thenAnswer((_) async => Right(testUser));

        // Act
        final result = await useCase.call(testEmail, testPassword, testName);

        // Assert
        expect(result, equals(Right(testUser)));
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).called(1);
      });

      test(
        'should return Right(User) when using function call syntax',
        () async {
          // Arrange
          when(
            mockAuthRepository.signUp(testEmail, testPassword, testName),
          ).thenAnswer((_) async => Right(testUser));

          // Act
          final result = await useCase(testEmail, testPassword, testName);

          // Assert
          expect(result, equals(Right(testUser)));
          verify(
            mockAuthRepository.signUp(testEmail, testPassword, testName),
          ).called(1);
        },
      );

      test('should return Left(Failure) when sign up fails', () async {
        // Arrange
        final failure = AuthFailure('Email already exists');
        when(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword, testName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).called(1);
      });

      test('should pass correct parameters to repository', () async {
        // Arrange
        const email = 'user@test.com';
        const password = 'secretPassword';
        const name = 'Jane Smith';
        const expectedUser = User(id: '456', email: email, name: name);

        when(
          mockAuthRepository.signUp(email, password, name),
        ).thenAnswer((_) async => Right(expectedUser));

        // Act
        await useCase.call(email, password, name);

        // Assert
        verify(mockAuthRepository.signUp(email, password, name)).called(1);
        verifyNever(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        );
      });

      test('should handle empty email', () async {
        // Arrange
        const emptyEmail = '';
        final failure = AuthFailure('Email cannot be empty');
        when(
          mockAuthRepository.signUp(emptyEmail, testPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(emptyEmail, testPassword, testName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(emptyEmail, testPassword, testName),
        ).called(1);
      });

      test('should handle empty password', () async {
        // Arrange
        const emptyPassword = '';
        final failure = AuthFailure('Password cannot be empty');
        when(
          mockAuthRepository.signUp(testEmail, emptyPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, emptyPassword, testName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(testEmail, emptyPassword, testName),
        ).called(1);
      });

      test('should handle empty name', () async {
        // Arrange
        const emptyName = '';
        final failure = AuthFailure('Name cannot be empty');
        when(
          mockAuthRepository.signUp(testEmail, testPassword, emptyName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword, emptyName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, emptyName),
        ).called(1);
      });

      test('should handle all empty parameters', () async {
        // Arrange
        const emptyEmail = '';
        const emptyPassword = '';
        const emptyName = '';
        final failure = AuthFailure('All fields are required');
        when(
          mockAuthRepository.signUp(emptyEmail, emptyPassword, emptyName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(emptyEmail, emptyPassword, emptyName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(emptyEmail, emptyPassword, emptyName),
        ).called(1);
      });

      test('should handle invalid email format', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        final failure = AuthFailure('Invalid email format');
        when(
          mockAuthRepository.signUp(invalidEmail, testPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(invalidEmail, testPassword, testName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(invalidEmail, testPassword, testName),
        ).called(1);
      });

      test('should handle weak password', () async {
        // Arrange
        const weakPassword = '123';
        final failure = AuthFailure('Password too weak');
        when(
          mockAuthRepository.signUp(testEmail, weakPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, weakPassword, testName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(testEmail, weakPassword, testName),
        ).called(1);
      });

      test('should handle email already exists failure', () async {
        // Arrange
        final failure = AuthFailure('Email already registered');
        when(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword, testName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).called(1);
      });

      test('should handle server failure', () async {
        // Arrange
        final failure = ServerFailure('Internal server error');
        when(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword, testName);

        // Assert
        expect(result, equals(Left(failure)));
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).called(1);
      });

      test('should handle special characters in all parameters', () async {
        // Arrange
        const specialEmail = 'test+user@example-domain.co.uk';
        const specialPassword = 'P@ssw0rd!2023#';
        const specialName = 'José María O\'Connor-Smith';
        const specialUser = User(
          id: '456',
          email: specialEmail,
          name: specialName,
        );

        when(
          mockAuthRepository.signUp(specialEmail, specialPassword, specialName),
        ).thenAnswer((_) async => Right(specialUser));

        // Act
        final result = await useCase.call(
          specialEmail,
          specialPassword,
          specialName,
        );

        // Assert
        expect(result, equals(Right(specialUser)));
        verify(
          mockAuthRepository.signUp(specialEmail, specialPassword, specialName),
        ).called(1);
      });

      test('should handle unicode characters in name', () async {
        // Arrange
        const unicodeName = '李小明 🌟';
        const unicodeUser = User(
          id: '789',
          email: testEmail,
          name: unicodeName,
        );

        when(
          mockAuthRepository.signUp(testEmail, testPassword, unicodeName),
        ).thenAnswer((_) async => Right(unicodeUser));

        // Act
        final result = await useCase.call(testEmail, testPassword, unicodeName);

        // Assert
        expect(result, equals(Right(unicodeUser)));
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, unicodeName),
        ).called(1);
      });

      test('should call repository method only once per invocation', () async {
        // Arrange
        when(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).thenAnswer((_) async => Right(testUser));

        // Act
        await useCase.call(testEmail, testPassword, testName);
        await useCase.call(testEmail, testPassword, testName);

        // Assert
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).called(2);
      });

      test('should handle different users on multiple calls', () async {
        // Arrange
        const email1 = 'user1@test.com';
        const password1 = 'password1';
        const name1 = 'User One';
        const email2 = 'user2@test.com';
        const password2 = 'password2';
        const name2 = 'User Two';
        const user1 = User(id: '1', email: email1, name: name1);
        const user2 = User(id: '2', email: email2, name: name2);

        when(
          mockAuthRepository.signUp(email1, password1, name1),
        ).thenAnswer((_) async => Right(user1));
        when(
          mockAuthRepository.signUp(email2, password2, name2),
        ).thenAnswer((_) async => Right(user2));

        // Act
        final result1 = await useCase.call(email1, password1, name1);
        final result2 = await useCase.call(email2, password2, name2);

        // Assert
        expect(result1, equals(Right(user1)));
        expect(result2, equals(Right(user2)));
        verify(mockAuthRepository.signUp(email1, password1, name1)).called(1);
        verify(mockAuthRepository.signUp(email2, password2, name2)).called(1);
      });

      test('should propagate exceptions from repository', () async {
        // Arrange
        final exception = Exception('Unexpected error');
        when(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () async => await useCase.call(testEmail, testPassword, testName),
          throwsA(equals(exception)),
        );
        verify(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).called(1);
      });

      test(
        'should handle async operations correctly with delayed response',
        () async {
          // Arrange
          when(
            mockAuthRepository.signUp(testEmail, testPassword, testName),
          ).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return Right(testUser);
          });

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await useCase.call(testEmail, testPassword, testName);
          stopwatch.stop();

          // Assert
          expect(result, equals(Right(testUser)));
          expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
          verify(
            mockAuthRepository.signUp(testEmail, testPassword, testName),
          ).called(1);
        },
      );
    });

    group('Either pattern validation', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testName = 'John Doe';
      const testUser = User(id: '123', email: testEmail, name: testName);

      test(
        'should return Either type that can be folded for success',
        () async {
          // Arrange
          when(
            mockAuthRepository.signUp(testEmail, testPassword, testName),
          ).thenAnswer((_) async => Right(testUser));

          // Act
          final result = await useCase.call(testEmail, testPassword, testName);

          // Assert
          final foldedResult = result.fold(
            (failure) => 'Failed: ${failure.message}',
            (user) => 'Success: ${user.name}',
          );
          expect(foldedResult, equals('Success: John Doe'));
        },
      );

      test(
        'should return Either type that can be folded for failure',
        () async {
          // Arrange
          final failure = AuthFailure('Email already exists');
          when(
            mockAuthRepository.signUp(testEmail, testPassword, testName),
          ).thenAnswer((_) async => Left(failure));

          // Act
          final result = await useCase.call(testEmail, testPassword, testName);

          // Assert
          final foldedResult = result.fold(
            (failure) => 'Failed: ${failure.message}',
            (user) => 'Success: ${user.name}',
          );
          expect(foldedResult, equals('Failed: Email already exists'));
        },
      );

      test('should return Either type that can be pattern matched', () async {
        // Arrange
        final failure = AuthFailure('Invalid input');
        when(
          mockAuthRepository.signUp(testEmail, testPassword, testName),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword, testName);

        // Assert
        result.fold(
          (l) => expect(l, isA<AuthFailure>()),
          (r) => fail('Expected Left but got Right'),
        );
      });
    });

    tearDown(() {
      reset(mockAuthRepository);
    });
  });
}
