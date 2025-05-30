import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/usecases/get_tasks.dart';
import 'package:task_manager/features/task/presentation/blocs/task/task_bloc.dart';

import 'task_bloc_test.mocks.dart';

@GenerateMocks([GetTasks])
void main() {
  group('TaskBloc', () {
    late TaskBloc taskBloc;
    late MockGetTasks mockGetTasks;

    setUp(() {
      mockGetTasks = MockGetTasks();
      taskBloc = TaskBloc(getTasks: mockGetTasks);
    });

    tearDown(() {
      taskBloc.close();
    });

    test('initial state should be TaskInitial', () {
      expect(taskBloc.state, equals(TaskInitial()));
    });

    group('GetTasksEvent', () {
      final tTasks = [
        Task(
          id: '1',
          title: 'Test Task 1',
          description: 'Test Description 1',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Test Task 2',
          description: 'Test Description 2',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
      ];

      blocTest<TaskBloc, TaskState>(
        'should emit [TaskLoading, TaskLoaded] when GetTasksEvent is successful',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasks));
          return taskBloc;
        },
        act: (bloc) async {
          bloc.add(GetTasksEvent());
          await Future.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [TaskLoading(), TaskLoaded(tasks: tTasks)],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should emit [TaskLoading, TaskError] when GetTasksEvent fails',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Left(ServerFailure('Server Error')));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        expect: () => [TaskLoading(), TaskError(message: 'Server Error')],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should emit [TaskLoading, TaskLoaded] with empty list when no tasks are returned',
        build: () {
          when(mockGetTasks.call()).thenAnswer((_) async => dartz.Right([]));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        expect: () => [TaskLoading(), TaskLoaded(tasks: [])],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should include 3-second delay before emitting result states',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasks));
          return taskBloc;
        },
        act: (bloc) => bloc.add(GetTasksEvent()),
        wait: const Duration(seconds: 4),
        expect: () => [TaskLoading(), TaskLoaded(tasks: tTasks)],
        verify: (_) {
          verify(mockGetTasks.call()).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'should handle multiple GetTasksEvent calls correctly',
        build: () {
          when(
            mockGetTasks.call(),
          ).thenAnswer((_) async => dartz.Right(tTasks));
          return taskBloc;
        },
        act: (bloc) {
          bloc.add(GetTasksEvent());
          bloc.add(GetTasksEvent());
        },
        wait: const Duration(seconds: 4),
        expect:
            () => [
              TaskLoading(),
              TaskLoaded(tasks: tTasks),
              TaskLoading(),
              TaskLoaded(tasks: tTasks),
            ],
        verify: (_) {
          verify(mockGetTasks.call()).called(2);
        },
      );
    });

    group('State Equality', () {
      test('TaskInitial instances should be equal', () {
        expect(TaskInitial(), equals(TaskInitial()));
      });

      test('TaskLoading instances should be equal', () {
        expect(TaskLoading(), equals(TaskLoading()));
      });

      test('TaskError instances with same message should be equal', () {
        const message = 'Test error';
        expect(
          TaskError(message: message),
          equals(TaskError(message: message)),
        );
      });

      test(
        'TaskError instances with different messages should not be equal',
        () {
          expect(
            TaskError(message: 'Error 1'),
            isNot(equals(TaskError(message: 'Error 2'))),
          );
        },
      );

      test('TaskLoaded instances with same tasks should be equal', () {
        final tasks = [
          Task(
            id: '1',
            title: 'Task 1',
            description: 'Description 1',
            isCompleted: false,
            createdAt: DateTime(2023, 1, 1),
          ),
        ];
        expect(TaskLoaded(tasks: tasks), equals(TaskLoaded(tasks: tasks)));
      });
    });
  });
}
