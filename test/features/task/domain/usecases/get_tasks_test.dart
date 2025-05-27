import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/repositories/task_repository.dart';
import 'package:task_manager/features/task/domain/usecases/get_tasks.dart';

// Generate mocks
@GenerateMocks([TaskRepository])
import 'get_tasks_test.mocks.dart';

void main() {
  late GetTasks usecase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    usecase = GetTasks(taskRepository: mockTaskRepository);
  });

  // Test data
  final tTask1 = Task(
    id: '1',
    title: 'Task 1',
    description: 'Description 1',
    isCompleted: false,
    createdAt: DateTime(2024, 1, 1),
  );

  final tTask2 = Task(
    id: '2',
    title: 'Task 2',
    description: 'Description 2',
    isCompleted: true,
    createdAt: DateTime(2024, 1, 2),
  );

  final tTasksList = [tTask1, tTask2];

  group('GetTasks', () {
    test('should get tasks from the repository', () async {
      // arrange
      when(
        mockTaskRepository.getTasks(),
      ).thenAnswer((_) async => dartz.Right(tTasksList));

      // act
      final result = await usecase();

      // assert
      expect(result, dartz.Right(tTasksList));
      verify(mockTaskRepository.getTasks());
      verifyNoMoreInteractions(mockTaskRepository);
    });

    test(
      'should return empty list when repository returns empty list',
      () async {
        // arrange
        when(
          mockTaskRepository.getTasks(),
        ).thenAnswer((_) async => dartz.Right(<Task>[]));

        // act
        final result = await usecase();

        // assert
        expect(result, dartz.Right(<Task>[]));
        verify(mockTaskRepository.getTasks());
        verifyNoMoreInteractions(mockTaskRepository);
      },
    );

    test('should return ServerFailure when repository fails', () async {
      // arrange
      final tServerFailure = ServerFailure('Server error');
      when(
        mockTaskRepository.getTasks(),
      ).thenAnswer((_) async => dartz.Left(tServerFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, dartz.Left(tServerFailure));
      verify(mockTaskRepository.getTasks());
      verifyNoMoreInteractions(mockTaskRepository);
    });

    test('should call repository getTasks only once', () async {
      // arrange
      when(
        mockTaskRepository.getTasks(),
      ).thenAnswer((_) async => dartz.Right(tTasksList));

      // act
      await usecase();

      // assert
      verify(mockTaskRepository.getTasks()).called(1);
    });

    test('should return the exact same result as repository', () async {
      // arrange
      final dartz.Either<Failure, List<Task>> expectedResult = dartz.Right(
        tTasksList,
      );
      when(
        mockTaskRepository.getTasks(),
      ).thenAnswer((_) async => expectedResult);

      // act
      final result = await usecase();

      // assert
      expect(result, equals(expectedResult));
      expect(result.fold((l) => l, (r) => r), equals(tTasksList));
    });

    test('should propagate any exception from repository', () async {
      // arrange
      when(
        mockTaskRepository.getTasks(),
      ).thenThrow(Exception('Unexpected error'));

      // act & assert
      expect(() => usecase(), throwsA(isA<Exception>()));
      verify(mockTaskRepository.getTasks());
    });
  });

  group('GetTasks constructor', () {
    test('should create instance with required repository', () {
      // act
      final usecase = GetTasks(taskRepository: mockTaskRepository);

      // assert
      expect(usecase, isNotNull);
      expect(usecase.taskRepository, equals(mockTaskRepository));
    });
  });

  group('GetTasks call method', () {
    test('should be callable as function', () async {
      // arrange
      when(
        mockTaskRepository.getTasks(),
      ).thenAnswer((_) async => dartz.Right(tTasksList));

      // act
      final result = await usecase.call();
      final resultWithParentheses = await usecase();

      // assert
      expect(result, equals(resultWithParentheses));
    });
  });
}
