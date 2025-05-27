import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';

// Generate mocks
@GenerateMocks([
  SignInUseCase,
  SignUpUseCase,
  SignOutUseCase,
  GetCurrentUserUseCase,
])
import 'auth_bloc_test.mocks.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockSignInUseCase mockSignInUseCase;
    late MockSignUpUseCase mockSignUpUseCase;
    late MockSignOutUseCase mockSignOutUseCase;
    late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

    const testUser = User(
      id: '123',
      email: 'test@example.com',
      name: 'John Doe',
    );

    setUp(() {
      mockSignInUseCase = MockSignInUseCase();
      mockSignUpUseCase = MockSignUpUseCase();
      mockSignOutUseCase = MockSignOutUseCase();
      mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

      authBloc = AuthBloc(
        signInUseCase: mockSignInUseCase,
        signUpUseCase: mockSignUpUseCase,
        signOutUseCase: mockSignOutUseCase,
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
      );
    });

    group('constructor', () {
      test('should have correct initial state', () {
        expect(authBloc.state, equals(Unauthenticated()));
      });

      test('should initialize with all required use cases', () {
        expect(authBloc.signInUseCase, equals(mockSignInUseCase));
        expect(authBloc.signUpUseCase, equals(mockSignUpUseCase));
        expect(authBloc.signOutUseCase, equals(mockSignOutUseCase));
        expect(
          authBloc.getCurrentUserUseCase,
          equals(mockGetCurrentUserUseCase),
        );
      });
    });

    group('SignInEvent', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when sign in succeeds',
        build: () {
          when(
            mockSignInUseCase.call(testEmail, testPassword),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act:
            (bloc) =>
                bloc.add(SignInEvent(email: testEmail, password: testPassword)),
        expect: () => [AuthLoading(), Authenticated()],
        verify: (_) {
          verify(mockSignInUseCase.call(testEmail, testPassword)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when sign in fails',
        build: () {
          final failure = AuthFailure('Invalid credentials');
          when(
            mockSignInUseCase.call(testEmail, testPassword),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        act:
            (bloc) =>
                bloc.add(SignInEvent(email: testEmail, password: testPassword)),
        expect:
            () => [
              AuthLoading(),
              AuthError(AuthFailure('Invalid credentials')),
            ],
        verify: (_) {
          verify(mockSignInUseCase.call(testEmail, testPassword)).called(1);
        },
      );

          blocTest<AuthBloc, AuthState>(
        'should handle validation failure during sign in',
        build: () {
          final failure = AuthFailure('Email cannot be empty');
          when(
            mockSignInUseCase.call('', testPassword),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignInEvent(email: '', password: testPassword)),
        expect:
            () => [
              AuthLoading(),
              AuthError(AuthFailure('Email cannot be empty')),
            ],
      );
    });

    group('SignUpEvent', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testName = 'John Doe';

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when sign up succeeds',
        build: () {
          when(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              SignUpEvent(
                email: testEmail,
                password: testPassword,
                name: testName,
              ),
            ),
        expect: () => [AuthLoading(), Authenticated()],
        verify: (_) {
          verify(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when sign up fails',
        build: () {
          final failure = AuthFailure('Email already exists');
          when(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              SignUpEvent(
                email: testEmail,
                password: testPassword,
                name: testName,
              ),
            ),
        expect:
            () => [
              AuthLoading(),
              AuthError(AuthFailure('Email already exists')),
            ],
        verify: (_) {
          verify(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should handle server failure during sign up',
        build: () {
          final failure = ServerFailure('Internal server error');
          when(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              SignUpEvent(
                email: testEmail,
                password: testPassword,
                name: testName,
              ),
            ),
        expect:
            () => [
              AuthLoading(),
              AuthError(ServerFailure('Internal server error')),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'should handle validation failure during sign up',
        build: () {
          final failure = AuthFailure('Password too weak');
          when(
            mockSignUpUseCase.call(testEmail, 'weak', testName),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              SignUpEvent(email: testEmail, password: 'weak', name: testName),
            ),
        expect:
            () => [AuthLoading(), AuthError(AuthFailure('Password too weak'))],
      );
    });

    group('CheckAuthStatusEvent', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [Authenticated] when user exists',
        build: () {
          when(
            mockGetCurrentUserUseCase.call(),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [Authenticated()],
        verify: (_) {
          verify(mockGetCurrentUserUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [Unauthenticated] when user is null',
        build: () {
          when(mockGetCurrentUserUseCase.call()).thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [Unauthenticated()],
        verify: (_) {
          verify(mockGetCurrentUserUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should handle exception during auth status check',
        build: () {
          when(
            mockGetCurrentUserUseCase.call(),
          ).thenThrow(Exception('Token expired'));
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        errors: () => [isA<Exception>()],
        verify: (_) {
          verify(mockGetCurrentUserUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should transition from loading state correctly',
        build: () {
          when(
            mockGetCurrentUserUseCase.call(),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        seed: () => AuthLoading(),
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [Authenticated()],
      );
    });

    group('SignOutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'should not emit any state changes (implementation empty)',
        build: () => authBloc,
        act: (bloc) => bloc.add(SignOutEvent()),
        expect: () => [],
      );

      blocTest<AuthBloc, AuthState>(
        'should maintain current state when sign out is triggered',
        build: () => authBloc,
        seed: () => Authenticated(),
        act: (bloc) => bloc.add(SignOutEvent()),
        expect: () => [],
      );
    });

    group('state transitions', () {
      blocTest<AuthBloc, AuthState>(
        'should transition from Unauthenticated to AuthLoading to Authenticated',
        build: () {
          when(
            mockSignInUseCase.call('test@example.com', 'password123'),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              SignInEvent(email: 'test@example.com', password: 'password123'),
            ),
        expect: () => [AuthLoading(), Authenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'should transition from Authenticated to AuthLoading to AuthError',
        build: () {
          final failure = AuthFailure('Connection lost');
          when(
            mockSignInUseCase.call('test@example.com', 'wrong'),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        seed: () => Authenticated(),
        act:
            (bloc) => bloc.add(
              SignInEvent(email: 'test@example.com', password: 'wrong'),
            ),
        expect:
            () => [AuthLoading(), AuthError(AuthFailure('Connection lost'))],
      );
    });

    group('edge cases', () {
      blocTest<AuthBloc, AuthState>(
        'should handle empty email and password in sign in',
        build: () {
          final failure = AuthFailure('Email and password required');
          when(
            mockSignInUseCase.call('', ''),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignInEvent(email: '', password: '')),
        expect:
            () => [
              AuthLoading(),
              AuthError(AuthFailure('Email and password required')),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'should handle empty fields in sign up',
        build: () {
          final failure = AuthFailure('All fields required');
          when(
            mockSignUpUseCase.call('', '', ''),
          ).thenAnswer((_) async => Left(failure));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignUpEvent(email: '', password: '', name: '')),
        expect:
            () => [
              AuthLoading(),
              AuthError(AuthFailure('All fields required')),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'should handle special characters in credentials',
        build: () {
          const specialEmail = 'test+user@example.com';
          const specialPassword = 'P@ssw0rd!';
          const specialName = 'José María';
          when(
            mockSignUpUseCase.call(specialEmail, specialPassword, specialName),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act: (bloc) {
          const specialEmail = 'test+user@example.com';
          const specialPassword = 'P@ssw0rd!';
          const specialName = 'José María';

          return bloc.add(
            SignUpEvent(
              email: specialEmail,
              password: specialPassword,
              name: specialName,
            ),
          );
        },
        expect: () => [AuthLoading(), Authenticated()],
      );
    });

    tearDown(() {
      authBloc.close();
    });
  });
}
