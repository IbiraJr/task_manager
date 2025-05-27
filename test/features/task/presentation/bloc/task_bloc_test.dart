import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/usecases/add_task.dart';
import 'package:task_manager/features/task/domain/usecases/get_tasks.dart';
import 'package:task_manager/features/task/presentation/bloc/task_bloc.dart';

// Generate mocks
@GenerateMocks([GetTasks, AddTask])
import 'task_bloc_test.mocks.dart';

void main() {
  late TaskBloc taskBloc;
  late MockGetTasks mockGetTasks;
  late MockAddTask mockAddTask;

  setUp(() {
    mockGetTasks = MockGetTasks();
    mockAddTask = MockAddTask();
    taskBloc = TaskBloc(getTasks: mockGetTasks, addTask: mockAddTask);
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

  group('TaskBloc', () {
    test('initial state should be TaskInitial', () {
      expect(taskBloc.state, equals(TaskInitial()));
    });

    group('GetTasksEvent', () {
      blocTest<TaskBloc, TaskState>(
        'should emit [TaskLoading, TaskLoaded] when getTasks returns data successfully',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasksList));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        expect: () => [TaskLoading(), TaskLoaded(tasks: tTasksList)],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should emit [TaskLoading, TaskLoaded] with empty list when getTasks returns empty list',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(<Task>[]));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        expect: () => [TaskLoading(), TaskLoaded(tasks: <Task>[])],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should emit [TaskLoading, TaskError] when getTasks returns ServerFailure',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Left(ServerFailure('Server error')));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        expect: () => [TaskLoading(), TaskError(message: 'Server error')],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
        },
      );
      blocTest<TaskBloc, TaskState>(
        'should wait for 3 seconds delay before emitting TaskLoaded',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasksList));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        wait: const Duration(seconds: 4), // Wait longer than the delay
        expect: () => [TaskLoading(), TaskLoaded(tasks: tTasksList)],
      );

      blocTest<TaskBloc, TaskState>(
        'should handle multiple GetTasksEvent calls correctly',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasksList));
          return taskBloc;
        },
        act: (bloc) {
          bloc.add(GetTasksEvent());
          bloc.add(GetTasksEvent());
        },
        expect:
            () => [
              TaskLoading(),
              TaskLoaded(tasks: tTasksList),
              TaskLoading(),
              TaskLoaded(tasks: tTasksList),
            ],
        verify: (_) {
          verify(mockGetTasks.call()).called(2);
        },
      );
    });

    group('AddTaskEvent', () {
      blocTest<TaskBloc, TaskState>(
        'should call addTask use case when AddTaskEvent is added',
        build: () {
          when(mockAddTask.call(any)).thenAnswer((_) async => {});
          return taskBloc;
        },
        act: (bloc) => bloc.add(AddTaskEvent(tTask1)),
        expect: () => [], // AddTask doesn't emit any state
        verify: (_) {
          verify(mockAddTask.call(tTask1)).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should not emit any state when AddTaskEvent is processed successfully',
        build: () {
          when(mockAddTask.call(any)).thenAnswer((_) async => {});
          return taskBloc;
        },
        act: (bloc) => bloc.add(AddTaskEvent(tTask1)),
        expect: () => [],
      );

      blocTest<TaskBloc, TaskState>(
        'should handle multiple AddTaskEvent calls',
        build: () {
          when(mockAddTask.call(any)).thenAnswer((_) async => {});
          return taskBloc;
        },
        act: (bloc) {
          bloc.add(AddTaskEvent(tTask1));
          bloc.add(AddTaskEvent(tTask2));
        },
        expect: () => [],
        verify: (_) {
          verify(mockAddTask.call(tTask1)).called(1);
          verify(mockAddTask.call(tTask2)).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should handle AddTaskEvent even when addTask throws exception',
        build: () {
          when(mockAddTask.call(any)).thenThrow(Exception('Add task failed'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(AddTaskEvent(tTask1)),
        errors: () => [isA<Exception>()],
        verify: (_) {
          verify(mockAddTask.call(tTask1)).called(1);
        },
      );
    });

    group('Mixed Events', () {
      blocTest<TaskBloc, TaskState>(
        'should handle AddTaskEvent followed by GetTasksEvent',
        build: () {
          when(mockAddTask.call(any)).thenAnswer((_) async => {});
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasksList));
          return taskBloc;
        },
        act: (bloc) {
          bloc.add(AddTaskEvent(tTask1));
          bloc.add(GetTasksEvent());
        },
        expect: () => [TaskLoading(), TaskLoaded(tasks: tTasksList)],
        verify: (_) {
          verify(mockAddTask.call(tTask1)).called(1);
          verify(mockGetTasks.call()).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should handle GetTasksEvent followed by AddTaskEvent',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasksList));
          when(mockAddTask.call(any)).thenAnswer((_) async => {});
          return taskBloc;
        },
        act: (bloc) {
          bloc.add(GetTasksEvent());
          bloc.add(AddTaskEvent(tTask1));
        },
        expect: () => [TaskLoading(), TaskLoaded(tasks: tTasksList)],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
          verify(mockAddTask.call(tTask1)).called(1);
        },
      );
    });

    group('Error Handling', () {
      blocTest<TaskBloc, TaskState>(
        'should handle when getTasks throws exception',
        build: () {
          when(mockGetTasks.call()).thenThrow(Exception('Unexpected error'));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        expect: () => [TaskLoading()],
        errors: () => [isA<Exception>()],
      );
    });
  });

  tearDown(() {
    taskBloc.close();
  });
}
