import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';

void main() {
  group('Task Entity', () {
    test('should create a task with all required properties', () {
      // Arrange
      const id = 'test-id';
      const title = 'Test Task';
      const description = 'Test Description';
      const isCompleted = false;
      final createdAt = DateTime.now();

      // Act
      final task = Task(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
        createdAt: createdAt,
      );

      // Assert
      expect(task.id, equals(id));
      expect(task.title, equals(title));
      expect(task.description, equals(description));
      expect(task.isCompleted, equals(isCompleted));
      expect(task.createdAt, equals(createdAt));
    });

    test('should support equality comparison', () {
      // Arrange
      final createdAt = DateTime.now();
      Task task1 = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        createdAt: createdAt,
      );
      Task task2 = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        createdAt: createdAt,
      );

      // Act & Assert
      expect(task1.id, equals(task2.id));
      expect(task1.title, equals(task2.title));
    });
  });
}
