import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';

void main() {
  const tUserModel = UserModel(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
  );

  const tJsonMap = {
    'id': '1',
    'email': 'test@example.com',
    'name': 'Test User',
  };

  group('UserModel', () {
    group('Constructor', () {
      test('should create UserModel with required parameters', () {
        // act
        const userModel = UserModel(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
        );

        // assert
        expect(userModel.id, '1');
        expect(userModel.email, 'test@example.com');
        expect(userModel.name, 'Test User');
      });

      test('should be a subclass of User entity', () {
        // assert
        expect(tUserModel, isA<User>());
      });
    });

    group('fromJson', () {
      test('should return a valid UserModel from JSON map', () {
        // act
        final result = UserModel.fromJson(tJsonMap);

        // assert
        expect(result, isA<UserModel>());
        expect(result.id, tJsonMap['id']);
        expect(result.email, tJsonMap['email']);
        expect(result.name, tJsonMap['name']);
      });

      test('should create UserModel from JSON string', () {
        // arrange
        final jsonString = json.encode(tJsonMap);
        final jsonMap = json.decode(jsonString);

        // act
        final result = UserModel.fromJson(jsonMap);

        // assert
        expect(result, equals(tUserModel));
      });

      test('should handle JSON with extra fields gracefully', () {
        // arrange
        final jsonWithExtra = {
          'id': '1',
          'email': 'test@example.com',
          'name': 'Test User',
          'extraField': 'should be ignored',
          'anotherExtra': 123,
        };

        // act
        final result = UserModel.fromJson(jsonWithExtra);

        // assert
        expect(result.id, '1');
        expect(result.email, 'test@example.com');
        expect(result.name, 'Test User');
      });

      test('should throw when required fields are missing', () {
        // arrange
        final incompleteJson = {
          'id': '1',
          'email': 'test@example.com',
          // 'name' is missing
        };

        // act & assert
        expect(
          () => UserModel.fromJson(incompleteJson),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tUserModel.toJson();

        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, equals(tJsonMap));
      });

      test('should contain all required fields in JSON', () {
        // act
        final result = tUserModel.toJson();

        // assert
        expect(result.containsKey('id'), true);
        expect(result.containsKey('email'), true);
        expect(result.containsKey('name'), true);
        expect(result.length, 3); // Ensure no extra fields
      });

      test('should produce JSON that can be converted back to UserModel', () {
        // act
        final json = tUserModel.toJson();
        final userFromJson = UserModel.fromJson(json);

        // assert
        expect(userFromJson, equals(tUserModel));
      });
    });

    group('JSON Serialization Round Trip', () {
      test('should maintain data integrity through JSON conversion cycle', () {
        // act
        final json = tUserModel.toJson();
        final jsonString = jsonEncode(json);
        final decodedJson = jsonDecode(jsonString);
        final recreatedUser = UserModel.fromJson(decodedJson);

        // assert
        expect(recreatedUser, equals(tUserModel));
        expect(recreatedUser.id, tUserModel.id);
        expect(recreatedUser.email, tUserModel.email);
        expect(recreatedUser.name, tUserModel.name);
      });

      test('should handle multiple conversion cycles', () {
        // act
        var currentUser = tUserModel;

        // Convert multiple times
        for (int i = 0; i < 3; i++) {
          final json = currentUser.toJson();
          currentUser = UserModel.fromJson(json);
        }

        // assert
        expect(currentUser, equals(tUserModel));
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        const user1 = UserModel(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
        );
        const user2 = UserModel(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
        );

        // assert
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        const user1 = UserModel(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
        );
        const user2 = UserModel(
          id: '2',
          email: 'test@example.com',
          name: 'Test User',
        );

        // assert
        expect(user1, isNot(equals(user2)));
      });

      test('should maintain equality after JSON conversion', () {
        // act
        final json = tUserModel.toJson();
        final userFromJson = UserModel.fromJson(json);

        // assert
        expect(userFromJson, equals(tUserModel));
        expect(userFromJson.hashCode, equals(tUserModel.hashCode));
      });
    });
  });
}
