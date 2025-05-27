import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/features/task/data/models/task_model.dart';
import 'package:task_manager/features/task/domain/entities/task.dart';

void main() {
  group('TaskModel', () {
    final testTaskModel = TaskModel(
      id: 'test-id',
      title: 'Test Task',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      isSynced: true,
    );

    test('should be a subclass of Task entity', () {
      // Assert
      expect(testTaskModel, isA<Task>());
    });

    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'test-id',
        'title': 'Test Task',
        'description': 'Test Description',
        'completed': 0,
        'created_at': '2024-01-01T00:00:00.000Z',
        'is_synced': 1,
      };

      // Act
      final result = TaskModel.fromJson(jsonMap);

      // Assert
      expect(result.id, equals('test-id'));
      expect(result.title, equals('Test Task'));
      expect(result.description, equals('Test Description'));
      expect(result.isCompleted, equals(false));
      expect(result.createdAt, equals(DateTime.parse('2024-01-01T00:00:00.000Z')));
      expect(result.isSynced, equals(true));
    });

    test('should return a JSON map containing proper data', () {
      // Act
      final result = testTaskModel.toJson();

      // Assert
      final expectedMap = {
        'id': 'test-id',
        'title': 'Test Task',
        'description': 'Test Description',
        'created_at': '2024-01-01T00:00:00.000Z',
        'is_completed': 0,
        'is_synced': 1,
      };
      expect(result, equals(expectedMap));
    });

    test('should handle completed task correctly in JSON conversion', () {
      // Arrange
      final completedTask = TaskModel(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: true,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        isSynced: false,
      );

      // Act
      final json = completedTask.toJson();
      final fromJson = TaskModel.fromJson({
        'id': 'test-id',
        'title': 'Test Task',
        'description': 'Test Description',
        'completed': 1,
        'created_at': '2024-01-01T00:00:00.000Z',
        'is_synced': 0,
      });

      // Assert
      expect(json['is_completed'], equals(1));
      expect(json['is_synced'], equals(0));
      expect(fromJson.isCompleted, equals(true));
      expect(fromJson.isSynced, equals(false));
    });
  });
}