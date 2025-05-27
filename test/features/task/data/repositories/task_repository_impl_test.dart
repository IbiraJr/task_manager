import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/core/network/network_info.dart';
import 'package:task_manager/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager/features/task/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/features/task/data/models/task_model.dart';
import 'package:task_manager/features/task/data/repositories/task_repository_impl.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';

// Generate mocks
@GenerateMocks([TaskLocalDataSource, TaskRemoteDataSource, NetworkInfo])
import 'task_repository_impl_test.mocks.dart';

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskLocalDataSource mockLocalDataSource;
  late MockTaskRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDataSource = MockTaskLocalDataSource();
    mockRemoteDataSource = MockTaskRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = TaskRepositoryImpl(
      taskLocalDataSource: mockLocalDataSource,
      taskRemoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  // Test data
  final tTaskModel = TaskModel(
    id: '1',
    title: 'Test Task',
    description: 'Test Description',
    isCompleted: false,
    createdAt: DateTime.now(),
    isSynced: true,
  );

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    description: 'Test Description',
    isCompleted: false,
    createdAt: DateTime.now(),
  );

  final tTasksList = [tTaskModel];

  group('getTasks', () {
    test(
      'should return remote tasks when device is connected and cache them locally',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockLocalDataSource.getTasks()).thenAnswer((_) async => []);
        when(
          mockRemoteDataSource.syncTasks(),
        ).thenAnswer((_) async => tTasksList);
        when(mockLocalDataSource.cacheTasks(any)).thenAnswer((_) async => {});

        // act
        final result = await repository.getTasks();

        // assert
        verify(mockRemoteDataSource.syncTasks());
        verify(mockLocalDataSource.cacheTasks(tTasksList));
        expect(result, equals(dartz.Right(tTasksList)));
      },
    );

    test('should return local tasks when device is not connected', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getTasks()).thenAnswer((_) async => tTasksList);

      // act
      final result = await repository.getTasks();

      // assert
      verify(mockLocalDataSource.getTasks());
      verifyNever(mockRemoteDataSource.syncTasks());
      verifyNever(mockLocalDataSource.cacheTasks(any));
      expect(result, equals(dartz.Right(tTasksList)));
    });

    test('should return ServerFailure when there is an exception', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        mockLocalDataSource.getTasks(),
      ).thenThrow(Exception('Database error'));

      // act
      final result = await repository.getTasks();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('addTask', () {
    test(
      'should add task to both remote and local when device is connected',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.addTask(any)).thenAnswer((_) async => {});
        when(mockLocalDataSource.addTask(any)).thenAnswer((_) async => {});

        // act
        await repository.addTask(tTask);

        // assert
        verify(mockRemoteDataSource.addTask(any));
        verify(mockLocalDataSource.addTask(any));
      },
    );

    test('should add task only locally when device is not connected', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.addTask(any)).thenAnswer((_) async => {});

      // act
      await repository.addTask(tTask);

      // assert
      verifyNever(mockRemoteDataSource.addTask(any));
      verify(mockLocalDataSource.addTask(any));
    });

    test(
      'should create TaskModel with correct isSynced flag when connected',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.addTask(any)).thenAnswer((_) async => {});
        when(mockLocalDataSource.addTask(any)).thenAnswer((_) async => {});

        // act
        await repository.addTask(tTask);

        // assert
        final captured =
            verify(mockLocalDataSource.addTask(captureAny)).captured.single
                as TaskModel;
        expect(captured.isSynced, true);
        expect(captured.title, tTask.title);
        expect(captured.description, tTask.description);
      },
    );

    test(
      'should create TaskModel with isSynced false when not connected',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.addTask(any)).thenAnswer((_) async => {});

        // act
        await repository.addTask(tTask);

        // assert
        final captured =
            verify(mockLocalDataSource.addTask(captureAny)).captured.single
                as TaskModel;
        expect(captured.isSynced, false);
      },
    );
  });

  group('syncPendingTasks', () {
    final tUnsyncedTasks = [
      TaskModel(
        id: '1',
        title: 'Unsynced Task 1',
        description: 'Description 1',
        isCompleted: false,
        createdAt: DateTime.now(),
        isSynced: false,
      ),
      TaskModel(
        id: '2',
        title: 'Unsynced Task 2',
        description: 'Description 2',
        isCompleted: true,
        createdAt: DateTime.now(),
        isSynced: false,
      ),
    ];

    test(
      'should sync all unsynced tasks to remote and mark them as synced',
      () async {
        // arrange
        when(
          mockLocalDataSource.getUnsyncedTasks(),
        ).thenAnswer((_) async => tUnsyncedTasks);
        when(mockRemoteDataSource.addTask(any)).thenAnswer((_) async => {});
        when(
          mockLocalDataSource.markTaskAsSynced(any),
        ).thenAnswer((_) async => {});

        // act
        await repository.syncPendingTasks();

        // assert
        verify(mockLocalDataSource.getUnsyncedTasks());
        verify(mockRemoteDataSource.addTask(tUnsyncedTasks[0]));
        verify(mockRemoteDataSource.addTask(tUnsyncedTasks[1]));
        verify(mockLocalDataSource.markTaskAsSynced('1'));
        verify(mockLocalDataSource.markTaskAsSynced('2'));
      },
    );

    test('should handle empty unsynced tasks list', () async {
      // arrange
      when(mockLocalDataSource.getUnsyncedTasks()).thenAnswer((_) async => []);

      // act
      await repository.syncPendingTasks();

      // assert
      verify(mockLocalDataSource.getUnsyncedTasks());
      verifyNever(mockRemoteDataSource.addTask(any));
      verifyNever(mockLocalDataSource.markTaskAsSynced(any));
    });

    test('should continue syncing remaining tasks if one fails', () async {
      // arrange
      when(
        mockLocalDataSource.getUnsyncedTasks(),
      ).thenAnswer((_) async => tUnsyncedTasks);
      when(
        mockRemoteDataSource.addTask(tUnsyncedTasks[0]),
      ).thenThrow(Exception('Network error'));
      when(
        mockRemoteDataSource.addTask(tUnsyncedTasks[1]),
      ).thenAnswer((_) async => {});
      when(
        mockLocalDataSource.markTaskAsSynced(any),
      ).thenAnswer((_) async => {});

      // act & assert
      expect(() => repository.syncPendingTasks(), throwsException);
    });
  });
}
