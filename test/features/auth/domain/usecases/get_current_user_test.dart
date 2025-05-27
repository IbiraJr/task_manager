import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_use_case.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
import 'get_current_user_test.mocks.dart';

void main() {
  group('GetCurrentUserUseCase', () {
    late GetCurrentUserUseCase useCase;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      useCase = GetCurrentUserUseCase(mockAuthRepository);
    });

    group('constructor', () {
      test('should initialize with AuthRepository', () {
        final repository = MockAuthRepository();
        final useCase = GetCurrentUserUseCase(repository);

        expect(useCase.authRepository, equals(repository));
      });
    });

    group('call', () {
      const testUser = User(
        id: '123',
        email: 'test@example.com',
        name: 'John Doe',
      );

      test(
        'should return User when repository returns user successfully',
        () async {
          // Arrange
          when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => testUser);

          // Act
          final result = await useCase.call();

          // Assert
          expect(result, equals(testUser));
          verify(mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      test('should return User when using function call syntax', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => testUser);

        // Act
        final result = await useCase();

        // Assert
        expect(result, equals(testUser));
        verify(mockAuthRepository.getCurrentUser()).called(1);
      });

      test('should return null when repository returns null', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => null);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isNull);
        verify(mockAuthRepository.getCurrentUser()).called(1);
      });

      test(
        'should propagate exception when repository throws exception',
        () async {
          // Arrange
          final exception = Exception('Authentication failed');
          when(mockAuthRepository.getCurrentUser()).thenThrow(exception);

          // Act & Assert
          expect(() async => await useCase.call(), throwsA(equals(exception)));
          verify(mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      test('should handle custom exceptions from repository', () async {
        // Arrange
        final customException = FormatException('Invalid token format');
        when(mockAuthRepository.getCurrentUser()).thenThrow(customException);

        // Act & Assert
        expect(
          () async => await useCase.call(),
          throwsA(isA<FormatException>()),
        );
        verify(mockAuthRepository.getCurrentUser()).called(1);
      });

      test('should call repository method only once per invocation', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => testUser);

        // Act
        await useCase.call();
        await useCase.call();

        // Assert
        verify(mockAuthRepository.getCurrentUser()).called(2);
      });

      test(
        'should handle repository returning different users on multiple calls',
        () async {
          // Arrange
          const user1 = User(id: '1', email: 'user1@test.com', name: 'User 1');
          const user2 = User(id: '2', email: 'user2@test.com', name: 'User 2');

          when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => user1);

          // Act
          final result1 = await useCase.call();

          // Change mock behavior for second call
          when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => user2);

          final result2 = await useCase.call();

          // Assert
          expect(result1, equals(user1));
          expect(result2, equals(user2));
          expect(result1, isNot(equals(result2)));
        },
      );
    });
  });
}
