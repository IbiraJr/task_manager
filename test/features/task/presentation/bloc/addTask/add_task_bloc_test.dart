import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/domain/usecases/add_task.dart';
import 'package:task_manager/features/task/presentation/blocs/add_task/add_task_bloc.dart';

import 'add_task_bloc_test.mocks.dart';

@GenerateMocks([AddTask])
void main() {
  group('AddTaskBloc', () {
    late AddTaskBloc addTaskBloc;
    late MockAddTask mockAddTask;

    setUp(() {
      mockAddTask = MockAddTask();
      addTaskBloc = AddTaskBloc(addTask: mockAddTask);
    });

    tearDown(() {
      addTaskBloc.close();
    });

    test('initial state should be AddTaskInitial', () {
      expect(addTaskBloc.state, equals(AddTaskInitial()));
    });

    group('SubmitTaskEvent', () {
      final tTask = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      blocTest<AddTaskBloc, AddTaskState>(
        'should emit [AddTaskLoading, TaskAdded] when SubmitTaskEvent is successful',
        build: () {
          when(
            mockAddTask.call(any),
          ).thenAnswer((_) async => dartz.Right(null));
          return addTaskBloc;
        },
        act: (bloc) => bloc.add(SubmitTaskEvent(tTask)),
        expect: () => [AddTaskLoading(), TaskAdded()],
        verify: (_) {
          verify(mockAddTask.call(tTask)).called(1);
        },
      );

      blocTest<AddTaskBloc, AddTaskState>(
        'should emit [AddTaskLoading, AddTaskError] when SubmitTaskEvent fails with server error',
        build: () {
          when(
            mockAddTask.call(any),
          ).thenAnswer((_) async => dartz.Left(ServerFailure('Server Error')));
          return addTaskBloc;
        },
        act: (bloc) => bloc.add(SubmitTaskEvent(tTask)),
        expect: () => [AddTaskLoading(), AddTaskError(message: 'Server Error')],
        verify: (_) {
          verify(mockAddTask.call(tTask)).called(1);
        },
      );

      blocTest<AddTaskBloc, AddTaskState>(
        'should pass correct task data to use case',
        build: () {
          when(
            mockAddTask.call(any),
          ).thenAnswer((_) async => dartz.Right(null));
          return addTaskBloc;
        },
        act: (bloc) => bloc.add(SubmitTaskEvent(tTask)),
        verify: (_) {
          final captured = verify(mockAddTask.call(captureAny)).captured;
          expect(captured.length, 1);
          final capturedTask = captured.first as Task;
          expect(capturedTask.id, equals(tTask.id));
          expect(capturedTask.title, equals(tTask.title));
          expect(capturedTask.description, equals(tTask.description));
          expect(capturedTask.isCompleted, equals(tTask.isCompleted));
        },
      );
    });

    group('State Equality', () {
      test('AddTaskInitial instances should be equal', () {
        expect(AddTaskInitial(), equals(AddTaskInitial()));
      });

      test('AddTaskLoading instances should be equal', () {
        expect(AddTaskLoading(), equals(AddTaskLoading()));
      });

      test('TaskAdded instances should be equal', () {
        expect(TaskAdded(), equals(TaskAdded()));
      });

      test('AddTaskError instances with same message should be equal', () {
        const message = 'Test error';
        expect(
          AddTaskError(message: message),
          equals(AddTaskError(message: message)),
        );
      });

      test(
        'AddTaskError instances with different messages should not be equal',
        () {
          expect(
            AddTaskError(message: 'Error 1'),
            isNot(equals(AddTaskError(message: 'Error 2'))),
          );
        },
      );
    });

    group('Event Equality', () {
      final task1 = Task(
        id: '1',
        title: 'Task 1',
        description: 'Description 1',
        isCompleted: false,
        createdAt: DateTime(2023, 1, 1),
      );

      final task2 = Task(
        id: '2',
        title: 'Task 2',
        description: 'Description 2',
        isCompleted: true,
        createdAt: DateTime(2023, 1, 2),
      );

      test('SubmitTaskEvent instances with same task should be equal', () {
        expect(SubmitTaskEvent(task1), equals(SubmitTaskEvent(task1)));
      });

      test(
        'SubmitTaskEvent instances with different tasks should not be equal',
        () {
          expect(SubmitTaskEvent(task1), isNot(equals(SubmitTaskEvent(task2))));
        },
      );
    });
  });
}
