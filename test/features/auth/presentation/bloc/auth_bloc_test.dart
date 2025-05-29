import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:task_manager/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';

import 'auth_bloc_test.mocks.dart';

// Generate mocks by running: flutter packages pub run build_runner build
@GenerateMocks([
  SignInUseCase,
  SignUpUseCase,
  SignOutUseCase,
  GetCurrentUserUseCase,
])
void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockSignInUseCase mockSignInUseCase;
    late MockSignUpUseCase mockSignUpUseCase;
    late MockSignOutUseCase mockSignOutUseCase;
    late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

    // Test data
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testName = 'Test User';
    const testUser = User(id: '1', email: testEmail, name: testName);
    final testFailure = ServerFailure('Something went wrong');

    setUpAll(() {
      // Provide dummy values for Mockito
      provideDummy<Either<Failure, User>>(Right(testUser));
      provideDummy<Either<Failure, void>>(const Right(null));
    });

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

    tearDown(() {
      authBloc.close();
      reset(mockSignInUseCase);
      reset(mockSignUpUseCase);
      reset(mockSignOutUseCase);
      reset(mockGetCurrentUserUseCase);
    });

    test('initial state should be Unauthenticated', () {
      expect(authBloc.state, equals(Unauthenticated()));
    });

    group('SignInEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when sign in succeeds',
        build: () {
          when(
            mockSignInUseCase.call(testEmail, testPassword),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act:
            (bloc) =>
                bloc.add(SignInEvent(email: testEmail, password: testPassword)),
        expect: () => [AuthLoading(), Authenticated(testUser)],
        verify: (_) {
          verify(mockSignInUseCase.call(testEmail, testPassword)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails',
        build: () {
          when(
            mockSignInUseCase.call(testEmail, testPassword),
          ).thenAnswer((_) async => Left(testFailure));
          return authBloc;
        },
        act:
            (bloc) =>
                bloc.add(SignInEvent(email: testEmail, password: testPassword)),
        expect: () => [AuthLoading(), AuthError(testFailure)],
        verify: (_) {
          verify(mockSignInUseCase.call(testEmail, testPassword)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'calls SignInUseCase with correct parameters',
        build: () {
          when(
            mockSignInUseCase.call(any, any),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act:
            (bloc) =>
                bloc.add(SignInEvent(email: testEmail, password: testPassword)),
        verify: (_) {
          verify(mockSignInUseCase.call(testEmail, testPassword)).called(1);
        },
      );
    });

    group('SignUpEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when sign up succeeds',
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
        expect: () => [AuthLoading(), Authenticated(testUser)],
        verify: (_) {
          verify(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails',
        build: () {
          when(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).thenAnswer((_) async => Left(testFailure));
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
        expect: () => [AuthLoading(), AuthError(testFailure)],
        verify: (_) {
          verify(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'calls SignUpUseCase with correct parameters',
        build: () {
          when(
            mockSignUpUseCase.call(any, any, any),
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
        verify: (_) {
          verify(
            mockSignUpUseCase.call(testEmail, testPassword, testName),
          ).called(1);
        },
      );
    });

    group('SignOutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError, Unauthenticated] when sign out fails',
        build: () {
          when(
            mockSignOutUseCase.call(),
          ).thenAnswer((_) async => Left(testFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignOutEvent()),
        expect:
            () => [AuthLoading(), AuthError(testFailure), Unauthenticated()],
        verify: (_) {
          verify(mockSignOutUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'always emits Unauthenticated as final state even when use case fails',
        build: () {
          when(
            mockSignOutUseCase.call(),
          ).thenAnswer((_) async => Left(testFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignOutEvent()),
        verify: (_) {
          // The final state should always be Unauthenticated
          expect(authBloc.state, equals(Unauthenticated()));
        },
      );
    });

    group('CheckAuthStatusEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Authenticated] when user is logged in',
        build: () {
          when(mockGetCurrentUserUseCase.call()).thenReturn(testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [Authenticated(testUser)],
        verify: (_) {
          verify(mockGetCurrentUserUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when no user is logged in',
        build: () {
          when(mockGetCurrentUserUseCase.call()).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [Unauthenticated()],
        verify: (_) {
          verify(mockGetCurrentUserUseCase.call()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'calls GetCurrentUserUseCase without parameters',
        build: () {
          when(mockGetCurrentUserUseCase.call()).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        verify: (_) {
          verify(mockGetCurrentUserUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGetCurrentUserUseCase);
        },
      );
    });

    group('Multiple events', () {
      blocTest<AuthBloc, AuthState>(
        'handles multiple events in sequence',
        build: () {
          when(
            mockSignInUseCase.call(testEmail, testPassword),
          ).thenAnswer((_) async => Right(testUser));
          when(
            mockSignOutUseCase.call(),
          ).thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) async {
          bloc.add(SignInEvent(email: testEmail, password: testPassword));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(SignOutEvent());
        },
        expect:
            () => [
              AuthLoading(),
              Authenticated(testUser),
              AuthLoading(),
              Unauthenticated(),
            ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles rapid fire events correctly',
        build: () {
          when(mockGetCurrentUserUseCase.call()).thenReturn(testUser);
          return authBloc;
        },
        act: (bloc) {
          // Add multiple CheckAuthStatusEvent rapidly
          bloc.add(CheckAuthStatusEvent());
          bloc.add(CheckAuthStatusEvent());
          bloc.add(CheckAuthStatusEvent());
        },
        verify: (_) {
          // Should be called for each event
          verify(mockGetCurrentUserUseCase.call()).called(3);
        },
      );
    });

    group('Error handling', () {
      blocTest<AuthBloc, AuthState>(
        'handles different types of failures correctly',
        build: () {
          final networkFailure = AuthFailure('No internet connection');
          when(
            mockSignInUseCase.call(testEmail, testPassword),
          ).thenAnswer((_) async => Left(networkFailure));
          return authBloc;
        },
        act:
            (bloc) =>
                bloc.add(SignInEvent(email: testEmail, password: testPassword)),
        expect:
            () => [
              AuthLoading(),
              AuthError(AuthFailure('No internet connection')),
            ],
      );
    });

    group('State equality', () {
      test('Authenticated states with same user are equal', () {
        final state1 = Authenticated(testUser);
        final state2 = Authenticated(testUser);
        expect(state1, equals(state2));
      });

      test('Unauthenticated states are equal', () {
        final state1 = Unauthenticated();
        final state2 = Unauthenticated();
        expect(state1, equals(state2));
      });

      test('AuthLoading states are equal', () {
        final state1 = AuthLoading();
        final state2 = AuthLoading();
        expect(state1, equals(state2));
      });

      test('AuthError states with same failure are equal', () {
        final state1 = AuthError(testFailure);
        final state2 = AuthError(testFailure);
        expect(state1, equals(state2));
      });
    });

    group('Event equality', () {
      test('SignInEvent with same parameters are equal', () {
        final event1 = SignInEvent(email: testEmail, password: testPassword);
        final event2 = SignInEvent(email: testEmail, password: testPassword);
        expect(event1, equals(event2));
      });

      test('SignUpEvent with same parameters are equal', () {
        final event1 = SignUpEvent(
          email: testEmail,
          password: testPassword,
          name: testName,
        );
        final event2 = SignUpEvent(
          email: testEmail,
          password: testPassword,
          name: testName,
        );
        expect(event1, equals(event2));
      });

      test('SignOutEvent instances are equal', () {
        final event1 = SignOutEvent();
        final event2 = SignOutEvent();
        expect(event1, equals(event2));
      });

      test('CheckAuthStatusEvent instances are equal', () {
        final event1 = CheckAuthStatusEvent();
        final event2 = CheckAuthStatusEvent();
        expect(event1, equals(event2));
      });
    });
  });
}
