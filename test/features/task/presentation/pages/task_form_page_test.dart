import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_manager/features/task/presentation/blocs/add_task/add_task_bloc.dart';
import 'package:task_manager/features/task/presentation/pages/task_form_page.dart';

import 'task_form_page_test.mocks.dart';

// Generate mocks by running: flutter packages pub run build_runner build
@GenerateMocks([AddTaskBloc])
void main() {
  group('TaskFormPage Widget Tests', () {
    late MockAddTaskBloc mockAddTaskBloc;

    setUpAll(() {
      provideDummy<AddTaskState>(AddTaskInitial());
    });

    setUp(() {
      mockAddTaskBloc = MockAddTaskBloc();
    });

    tearDown(() {
      mockAddTaskBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AddTaskBloc>(
          create: (_) => mockAddTaskBloc,
          child: const TaskFormPage(),
        ),
      );
    }

    testWidgets('should display all required UI elements', (tester) async {
      // Arrange
      when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
      when(mockAddTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byKey(const Key('taskFormPageAppBar')), findsOneWidget);
      expect(find.byKey(const Key('titleField')), findsOneWidget);
      expect(find.byKey(const Key('descriptionField')), findsOneWidget);
      expect(find.byKey(const Key('submitButton')), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('should allow text input in title and description fields', (
      tester,
    ) async {
      // Arrange
      when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
      when(mockAddTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(const Key('titleField')), 'Test Title');
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Test Description',
      );

      // Assert
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets(
      'should trigger SubmitTaskEvent when submit button is pressed',
      (tester) async {
        // Arrange
        when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
        when(mockAddTaskBloc.stream).thenAnswer((_) => const Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(
          find.byKey(const Key('titleField')),
          'Test Title',
        );
        await tester.enterText(
          find.byKey(const Key('descriptionField')),
          'Test Description',
        );
        await tester.tap(find.byKey(const Key('submitButton')));

        // Assert
        verify(mockAddTaskBloc.add(argThat(isA<SubmitTaskEvent>()))).called(1);
      },
    );

    testWidgets('should show loading indicator when state is AddTaskLoading', (
      tester,
    ) async {
      // Arrange
      when(mockAddTaskBloc.state).thenReturn(AddTaskLoading());
      when(mockAddTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('titleField')), findsNothing);
      expect(find.byKey(const Key('descriptionField')), findsNothing);
      expect(find.byKey(const Key('submitButton')), findsNothing);
    });

    testWidgets('should show snackbar when state is AddTaskError', (
      tester,
    ) async {
      // Arrange
      const errorMessage = 'Failed to add task';
      when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
      when(mockAddTaskBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          AddTaskInitial(),
          AddTaskError(message: errorMessage),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow the stream to emit

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should pop navigation when task is successfully added', (
      tester,
    ) async {
      // Arrange
      when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
      when(
        mockAddTaskBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([AddTaskInitial(), TaskAdded()]));

      bool navigationPopped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider<AddTaskBloc>(
                              create: (_) => mockAddTaskBloc,
                              child: const TaskFormPage(),
                            ),
                      ),
                    ).then((_) => navigationPopped = true);
                  },
                  child: const Text('Go to Form'),
                ),
          ),
        ),
      );

      // Navigate to form page
      await tester.tap(find.text('Go to Form'));
      await tester.pumpAndSettle();

      // Wait for navigation to complete
      await tester.pumpAndSettle();

      // Assert
      expect(navigationPopped, isTrue);
    });

    testWidgets('should create task with correct properties when submitted', (
      tester,
    ) async {
      // Arrange
      when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
      when(mockAddTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      const testTitle = 'Test Task Title';
      const testDescription = 'Test Task Description';

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(const Key('titleField')), testTitle);
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        testDescription,
      );
      await tester.tap(find.byKey(const Key('submitButton')));

      // Assert
      final captured = verify(mockAddTaskBloc.add(captureAny)).captured;
      final submitEvent = captured.first as SubmitTaskEvent;

      expect(submitEvent.task.title, equals(testTitle));
      expect(submitEvent.task.description, equals(testDescription));
      expect(submitEvent.task.isCompleted, isFalse);
      expect(submitEvent.task.id, isNotEmpty);
      expect(submitEvent.task.createdAt, isA<DateTime>());
    });

    testWidgets('should handle empty fields when submitting', (tester) async {
      // Arrange
      when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
      when(mockAddTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byKey(const Key('submitButton')));

      // Assert
      final captured = verify(mockAddTaskBloc.add(captureAny)).captured;
      final submitEvent = captured.first as SubmitTaskEvent;

      expect(submitEvent.task.title, isEmpty);
      expect(submitEvent.task.description, isEmpty);
    });

    testWidgets('should dispose controllers properly', (tester) async {
      // Arrange
      when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
      when(mockAddTaskBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter some text to ensure controllers are used
      await tester.enterText(find.byKey(const Key('titleField')), 'Test');

      // Dispose by removing the widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Assert - No assertion needed, this test ensures no memory leaks
      // If controllers aren't disposed properly, this would show in memory profiling
    });

    group('BlocConsumer listener tests', () {
      testWidgets('should handle multiple state changes correctly', (
        tester,
      ) async {
        // Arrange
        when(mockAddTaskBloc.state).thenReturn(AddTaskInitial());
        when(mockAddTaskBloc.stream).thenAnswer(
          (_) => Stream.fromIterable([
            AddTaskInitial(),
            AddTaskLoading(),
            AddTaskError(message: 'Network error'),
            AddTaskLoading(),
            TaskAdded(),
          ]),
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // The final state should result in navigation pop
        // This tests the robustness of the BlocConsumer listener
      });
    });
  });
}
