import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/features/auth/domain/entities/user.dart';

void main() {
  group('User', () {
    const testId = '123';
    const testEmail = 'test@example.com';
    const testName = 'John Doe';

    test('should create User with required parameters', () {
      const user = User(id: testId, email: testEmail, name: testName);

      expect(user.id, equals(testId));
      expect(user.email, equals(testEmail));
      expect(user.name, equals(testName));
    });

    test('should return correct props', () {
      const user = User(id: testId, email: testEmail, name: testName);

      expect(user.props, equals([testId, testEmail, testName]));
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        const user1 = User(id: testId, email: testEmail, name: testName);
        const user2 = User(id: testId, email: testEmail, name: testName);

        expect(user1, equals(user2));
        expect(user1 == user2, isTrue);
      });

      test('should not be equal when id is different', () {
        const user1 = User(id: '123', email: testEmail, name: testName);
        const user2 = User(id: '456', email: testEmail, name: testName);

        expect(user1, isNot(equals(user2)));
        expect(user1 == user2, isFalse);
      });

      test('should not be equal when email is different', () {
        const user1 = User(
          id: testId,
          email: 'test1@example.com',
          name: testName,
        );
        const user2 = User(
          id: testId,
          email: 'test2@example.com',
          name: testName,
        );

        expect(user1, isNot(equals(user2)));
        expect(user1 == user2, isFalse);
      });

      test('should not be equal when name is different', () {
        const user1 = User(id: testId, email: testEmail, name: 'John Doe');
        const user2 = User(id: testId, email: testEmail, name: 'Jane Doe');

        expect(user1, isNot(equals(user2)));
        expect(user1 == user2, isFalse);
      });
    });

    group('hashCode', () {
      test('should have same hashCode when objects are equal', () {
        const user1 = User(id: testId, email: testEmail, name: testName);
        const user2 = User(id: testId, email: testEmail, name: testName);

        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should have different hashCode when objects are not equal', () {
        const user1 = User(id: '123', email: testEmail, name: testName);
        const user2 = User(id: '456', email: testEmail, name: testName);

        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });
    });

    group('toString', () {
      test('should return string representation with all properties', () {
        const user = User(id: testId, email: testEmail, name: testName);

        final result = user.toString();

        expect(result, contains('User'));
        expect(result, contains(testId));
        expect(result, contains(testEmail));
        expect(result, contains(testName));
      });
    });

    group('edge cases', () {
      test('should handle empty strings', () {
        const user = User(id: '', email: '', name: '');

        expect(user.id, equals(''));
        expect(user.email, equals(''));
        expect(user.name, equals(''));
        expect(user.props, equals(['', '', '']));
      });

      test('should handle special characters in properties', () {
        const specialId = '123-abc_def';
        const specialEmail = 'test+user@example-domain.co.uk';
        const specialName = 'José María O\'Connor';

        const user = User(
          id: specialId,
          email: specialEmail,
          name: specialName,
        );

        expect(user.id, equals(specialId));
        expect(user.email, equals(specialEmail));
        expect(user.name, equals(specialName));
      });
    });
  });
}
