import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';
import 'package:task_manager/features/task/presentation/blocs/task/task_bloc.dart';
import 'package:task_manager/features/task/presentation/pages/task_list_page.dart';
import 'package:task_manager/features/task/presentation/components/task_card.dart';

import 'task_list_page_test.mocks.dart';

// Generate mocks by running: flutter packages pub run build_runner build
@GenerateMocks([AuthBloc, TaskBloc, GoRouter])
void main() {
  group('TaskListPage Widget Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockTaskBloc mockTaskBloc;

    setUpAll(() {
      provideDummy<TaskState>(TaskInitial());
      provideDummy<AuthState>(
        Authenticated(
          User(id: '1', name: 'John Doe', email: 'john@example.com'),
        ),
      );
    });
    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockTaskBloc = MockTaskBloc();
    });

    tearDown(() {
      mockAuthBloc.close();
      mockTaskBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => mockAuthBloc),
            BlocProvider<TaskBloc>(create: (_) => mockTaskBloc),
          ],
          child: const TaskListPage(),
        ),
      );
    }

    group('AuthBloc States', () {
      testWidgets('should show loading indicator when AuthLoading', (
        tester,
      ) async {
        // Arrange
        when(mockAuthBloc.state).thenReturn(AuthLoading());
        when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
        when(mockTaskBloc.state).thenReturn(TaskInitial());
        when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(Scaffold), findsNothing);
      });

      testWidgets(
        'should show error message when auth state is not Authenticated',
        (tester) async {
          // Arrange
          when(mockAuthBloc.state).thenReturn(Unauthenticated());
          when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
          when(mockTaskBloc.state).thenReturn(TaskInitial());
          when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

          // Act
          await tester.pumpWidget(createWidgetUnderTest());

          // Assert
          expect(find.text('Something went wrong'), findsOneWidget);
          expect(find.byType(Scaffold), findsNothing);
        },
      );

      testWidgets('should show main UI when Authenticated', (tester) async {
        // Arrange
        final mockUser = User(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
        );
        when(mockAuthBloc.state).thenReturn(Authenticated(mockUser));
        when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
        when(mockTaskBloc.state).thenReturn(TaskInitial());
        when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Task List - John Doe'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    group('AppBar Actions', () {
      testWidgets('should trigger SignOutEvent when logout button is pressed', (
        tester,
      ) async {
        // Arrange
        final mockUser = User(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
        );
        when(mockAuthBloc.state).thenReturn(Authenticated(mockUser));
        when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
        when(mockTaskBloc.state).thenReturn(TaskInitial());
        when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.byIcon(Icons.logout));

        // Assert
        verify(mockAuthBloc.add(argThat(isA<SignOutEvent>()))).called(1);
      });
    });
  });

  group('TaskListWidget Tests', () {
    late MockTaskBloc mockTaskBloc;

    setUp(() {
      mockTaskBloc = MockTaskBloc();
    });
    setUpAll(() {
      provideDummy<TaskState>(TaskInitial());
    });

    tearDown(() {
      mockTaskBloc.close();
    });

    Widget createTaskListWidget() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<TaskBloc>(
            create: (_) => mockTaskBloc,
            child: const TaskListWidget(),
          ),
        ),
      );
    }

    testWidgets('should show loading indicator when TaskLoading', (
      tester,
    ) async {
      // Arrange
      when(mockTaskBloc.state).thenReturn(TaskLoading());
      when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTaskListWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'should show "No tasks found" when TaskLoaded with empty list',
      (tester) async {
        // Arrange
        when(mockTaskBloc.state).thenReturn(TaskLoaded(tasks: []));
        when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTaskListWidget());

        // Assert
        expect(find.text('No tasks found'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      },
    );

    testWidgets(
      'should show ListView with TaskCards when TaskLoaded with tasks',
      (tester) async {
        // Arrange
        final tasks = [
          Task(
            id: '1',
            title: 'Task 1',
            description: 'Description 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '2',
            title: 'Task 2',
            description: 'Description 2',
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];
        when(mockTaskBloc.state).thenReturn(TaskLoaded(tasks: tasks));
        when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createTaskListWidget());

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(TaskCard), findsNWidgets(2));
        expect(find.text('Task 1'), findsOneWidget);
        expect(find.text('Task 2'), findsOneWidget);
        expect(find.text('Description 1'), findsOneWidget);
        expect(find.text('Description 2'), findsOneWidget);
      },
    );

    testWidgets('should show error message when TaskError', (tester) async {
      // Arrange
      const errorMessage = 'Failed to load tasks';
      when(mockTaskBloc.state).thenReturn(TaskError(message: errorMessage));
      when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTaskListWidget());

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should show fallback message for unknown state', (
      tester,
    ) async {
      // Arrange
      when(mockTaskBloc.state).thenReturn(TaskInitial());
      when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTaskListWidget());

      // Assert
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should display correct number of separators in ListView', (
      tester,
    ) async {
      // Arrange
      final tasks = List.generate(
        5,
        (index) => Task(
          id: '$index',
          title: 'Task $index',
          description: 'Description $index',
          isCompleted: index % 2 == 0,
          createdAt: DateTime.now(),
        ),
      );
      when(mockTaskBloc.state).thenReturn(TaskLoaded(tasks: tasks));
      when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTaskListWidget());

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(TaskCard), findsNWidgets(5));
      expect(find.byType(Divider), findsNWidgets(4)); // n-1 separators
    });

    testWidgets('should handle state changes correctly', (tester) async {
      // Arrange
      when(mockTaskBloc.state).thenReturn(TaskLoading());
      when(mockTaskBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          TaskLoading(),
          TaskLoaded(
            tasks: [
              Task(
                id: '1',
                title: 'Test Task',
                description: 'Test Description',
                isCompleted: false,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(createTaskListWidget());

      // Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After state change should show tasks
      await tester.pump();
      expect(find.byType(TaskCard), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
    });
  });

  group('Integration between AuthBloc and TaskBloc', () {
    late MockAuthBloc mockAuthBloc;
    late MockTaskBloc mockTaskBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockTaskBloc = MockTaskBloc();
    });

    tearDown(() {
      mockAuthBloc.close();
      mockTaskBloc.close();
    });

    testWidgets(
      'should show complete UI when both blocs are in correct state',
      (tester) async {
        // Arrange
        final mockUser = User(
          id: '1',
          name: 'Alice Smith',
          email: 'alice@example.com',
        );
        final tasks = [
          Task(
            id: '1',
            title: 'Complete project',
            description: 'Finish the Flutter project',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];

        when(mockAuthBloc.state).thenReturn(Authenticated(mockUser));
        when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
        when(mockTaskBloc.state).thenReturn(TaskLoaded(tasks: tasks));
        when(mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(create: (_) => mockAuthBloc),
                BlocProvider<TaskBloc>(create: (_) => mockTaskBloc),
              ],
              child: const TaskListPage(),
            ),
          ),
        );

        // Assert
        expect(find.text('Task List - Alice Smith'), findsOneWidget);
        expect(find.byType(TaskCard), findsOneWidget);
        expect(find.text('Complete project'), findsOneWidget);
        expect(find.text('Finish the Flutter project'), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      },
    );
  });
}
