import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_use_case.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
import 'sign_in_test.mocks.dart';

void main() {
  group('SignInUseCase', () {
    late SignInUseCase useCase;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      useCase = SignInUseCase(mockAuthRepository);
    });

    group('constructor', () {
      test('should initialize with AuthRepository', () {
        final repository = MockAuthRepository();
        final useCase = SignInUseCase(repository);

        expect(useCase.authRepository, equals(repository));
      });
    });

    group('call', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUser = User(id: '123', email: testEmail, name: 'John Doe');

      test('should return Right(User) when sign in is successful', () async {
        // Arrange
        when(
          mockAuthRepository.signIn(testEmail, testPassword),
        ).thenAnswer((_) async => Right(testUser));

        // Act
        final result = await useCase.call(testEmail, testPassword);

        // Assert
        expect(result, equals(Right(testUser)));
        verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
      });

      test(
        'should return Right(User) when using function call syntax',
        () async {
          // Arrange
          when(
            mockAuthRepository.signIn(testEmail, testPassword),
          ).thenAnswer((_) async => Right(testUser));

          // Act
          final result = await useCase(testEmail, testPassword);

          // Assert
          expect(result, equals(Right(testUser)));
          verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
        },
      );

      test('should return Left(Failure) when sign in fails', () async {
        // Arrange
        final failure = AuthFailure('Invalid credentials');
        when(
          mockAuthRepository.signIn(testEmail, testPassword),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword);

        // Assert
        expect(result, equals(Left(failure)));
        verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
      });

      test('should pass correct parameters to repository', () async {
        // Arrange
        const email = 'user@test.com';
        const password = 'secretPassword';
        when(
          mockAuthRepository.signIn(email, password),
        ).thenAnswer((_) async => Right(testUser));

        // Act
        await useCase.call(email, password);

        // Assert
        verify(mockAuthRepository.signIn(email, password)).called(1);
        verifyNever(mockAuthRepository.signIn(testEmail, testPassword));
      });

      test('should handle empty email', () async {
        // Arrange
        const emptyEmail = '';
        final failure = AuthFailure('Email cannot be empty');
        when(
          mockAuthRepository.signIn(emptyEmail, testPassword),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(emptyEmail, testPassword);

        // Assert
        expect(result, equals(Left(failure)));
        verify(mockAuthRepository.signIn(emptyEmail, testPassword)).called(1);
      });

      test('should handle empty password', () async {
        // Arrange
        const emptyPassword = '';
        final failure = AuthFailure('Password cannot be empty');
        when(
          mockAuthRepository.signIn(testEmail, emptyPassword),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, emptyPassword);

        // Assert
        expect(result, equals(Left(failure)));
        verify(mockAuthRepository.signIn(testEmail, emptyPassword)).called(1);
      });

      test('should handle server failure', () async {
        // Arrange
        final failure = ServerFailure('Internal server error');
        when(
          mockAuthRepository.signIn(testEmail, testPassword),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword);

        // Assert
        expect(result, equals(Left(failure)));
        verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
      });

      test('should handle special characters in email and password', () async {
        // Arrange
        const specialEmail = 'test+user@example-domain.co.uk';
        const specialPassword = 'P@ssw0rd!2023#';
        const specialUser = User(
          id: '456',
          email: specialEmail,
          name: 'Special User',
        );
        when(
          mockAuthRepository.signIn(specialEmail, specialPassword),
        ).thenAnswer((_) async => Right(specialUser));

        // Act
        final result = await useCase.call(specialEmail, specialPassword);

        // Assert
        expect(result, equals(Right(specialUser)));
        verify(
          mockAuthRepository.signIn(specialEmail, specialPassword),
        ).called(1);
      });

      test('should call repository method only once per invocation', () async {
        // Arrange
        when(
          mockAuthRepository.signIn(testEmail, testPassword),
        ).thenAnswer((_) async => Right(testUser));

        // Act
        await useCase.call(testEmail, testPassword);
        await useCase.call(testEmail, testPassword);

        // Assert
        verify(mockAuthRepository.signIn(testEmail, testPassword)).called(2);
      });

      test('should handle different credentials on multiple calls', () async {
        // Arrange
        const email1 = 'user1@test.com';
        const password1 = 'password1';
        const email2 = 'user2@test.com';
        const password2 = 'password2';
        const user1 = User(id: '1', email: email1, name: 'User 1');
        const user2 = User(id: '2', email: email2, name: 'User 2');

        when(
          mockAuthRepository.signIn(email1, password1),
        ).thenAnswer((_) async => Right(user1));
        when(
          mockAuthRepository.signIn(email2, password2),
        ).thenAnswer((_) async => Right(user2));

        // Act
        final result1 = await useCase.call(email1, password1);
        final result2 = await useCase.call(email2, password2);

        // Assert
        expect(result1, equals(Right(user1)));
        expect(result2, equals(Right(user2)));
        verify(mockAuthRepository.signIn(email1, password1)).called(1);
        verify(mockAuthRepository.signIn(email2, password2)).called(1);
      });

      test('should propagate exceptions from repository', () async {
        // Arrange
        final exception = Exception('Unexpected error');
        when(
          mockAuthRepository.signIn(testEmail, testPassword),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () async => await useCase.call(testEmail, testPassword),
          throwsA(equals(exception)),
        );
        verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
      });

      test(
        'should handle async operations correctly with delayed response',
        () async {
          // Arrange
          when(mockAuthRepository.signIn(testEmail, testPassword)).thenAnswer((
            _,
          ) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return Right(testUser);
          });

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await useCase.call(testEmail, testPassword);
          stopwatch.stop();

          // Assert
          expect(result, equals(Right(testUser)));
          expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
          verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
        },
      );
    });

    group('Either pattern validation', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUser = User(id: '123', email: testEmail, name: 'John Doe');

      test('should return Either type that can be folded', () async {
        // Arrange
        when(
          mockAuthRepository.signIn(testEmail, testPassword),
        ).thenAnswer((_) async => Right(testUser));

        // Act
        final result = await useCase.call(testEmail, testPassword);

        // Assert
        final foldedResult = result.fold(
          (failure) => 'Failed: ${failure.message}',
          (user) => 'Success: ${user.name}',
        );
        expect(foldedResult, equals('Success: John Doe'));
      });

      test('should return Either type that can be pattern matched', () async {
        // Arrange
        final failure = AuthFailure('Invalid credentials');
        when(
          mockAuthRepository.signIn(testEmail, testPassword),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(testEmail, testPassword);

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
