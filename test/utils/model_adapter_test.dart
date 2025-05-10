import 'package:flutter_test/flutter_test.dart';
import 'package:finalworkvibe/core/utils/model_adapter.dart';

void main() {
  final adapter = ModelAdapter();

  group('ModelAdapter', () {
    test('toFreezedJson converts snake_case to camelCase', () {
      final supabaseJson = {
        'user_id': '123',
        'first_name': 'John',
        'last_name': 'Doe',
        'created_at': '2023-01-01T12:00:00Z',
        'is_active': true,
      };

      final result = adapter.toFreezedJson(supabaseJson);

      expect(result.containsKey('userId'), true);
      expect(result.containsKey('firstName'), true);
      expect(result.containsKey('lastName'), true);
      expect(result.containsKey('createdAt'), true);
      expect(result.containsKey('isActive'), true);
      
      expect(result['userId'], equals('123'));
      expect(result['firstName'], equals('John'));
      expect(result['lastName'], equals('Doe'));
      expect(result['isActive'], equals(true));
      
      // Date conversion
      expect(result['createdAt'], isA<DateTime>());
      expect((result['createdAt'] as DateTime).year, equals(2023));
      expect((result['createdAt'] as DateTime).month, equals(1));
      expect((result['createdAt'] as DateTime).day, equals(1));
    });

    test('toSupabaseJson converts camelCase to snake_case', () {
      final freezedJson = {
        'userId': '123',
        'firstName': 'John',
        'lastName': 'Doe',
        'createdAt': DateTime(2023, 1, 1, 12),
        'isActive': true,
      };

      final result = adapter.toSupabaseJson(freezedJson);

      expect(result.containsKey('user_id'), true);
      expect(result.containsKey('first_name'), true);
      expect(result.containsKey('last_name'), true);
      expect(result.containsKey('created_at'), true);
      expect(result.containsKey('is_active'), true);
      
      expect(result['user_id'], equals('123'));
      expect(result['first_name'], equals('John'));
      expect(result['last_name'], equals('Doe'));
      expect(result['is_active'], equals(true));
      
      // Date conversion
      expect(result['created_at'], isA<String>());
      expect(result['created_at'], contains('2023-01-01'));
    });

    test('toFreezedJson handles nested objects', () {
      final supabaseJson = {
        'user_id': '123',
        'user_profile': {
          'avatar_url': 'http://example.com/avatar.jpg',
          'phone_number': '555-1234',
        },
      };

      final result = adapter.toFreezedJson(supabaseJson);

      expect(result.containsKey('userId'), true);
      expect(result.containsKey('userProfile'), true);
      
      final profile = result['userProfile'] as Map<String, dynamic>;
      expect(profile.containsKey('avatarUrl'), true);
      expect(profile.containsKey('phoneNumber'), true);
      expect(profile['avatarUrl'], equals('http://example.com/avatar.jpg'));
      expect(profile['phoneNumber'], equals('555-1234'));
    });

    test('toSupabaseJson handles nested objects', () {
      final freezedJson = {
        'userId': '123',
        'userProfile': {
          'avatarUrl': 'http://example.com/avatar.jpg',
          'phoneNumber': '555-1234',
        },
      };

      final result = adapter.toSupabaseJson(freezedJson);

      expect(result.containsKey('user_id'), true);
      expect(result.containsKey('user_profile'), true);
      
      final profile = result['user_profile'] as Map<String, dynamic>;
      expect(profile.containsKey('avatar_url'), true);
      expect(profile.containsKey('phone_number'), true);
      expect(profile['avatar_url'], equals('http://example.com/avatar.jpg'));
      expect(profile['phone_number'], equals('555-1234'));
    });

    test('toFreezedJson handles lists', () {
      final supabaseJson = {
        'user_id': '123',
        'task_ids': ['task1', 'task2', 'task3'],
        'scheduled_dates': [
          '2023-01-01T12:00:00Z',
          '2023-01-02T12:00:00Z',
        ],
        'items': [
          {'item_id': '1', 'item_name': 'Item 1'},
          {'item_id': '2', 'item_name': 'Item 2'},
        ],
      };

      final result = adapter.toFreezedJson(supabaseJson);
      
      expect(result['taskIds'], isA<List>());
      expect(result['taskIds'].length, equals(3));
      expect(result['taskIds'][0], equals('task1'));
      
      expect(result['scheduledDates'], isA<List>());
      expect(result['scheduledDates'][0], isA<DateTime>());
      
      expect(result['items'], isA<List>());
      final items = result['items'] as List;
      expect(items.length, equals(2));
      
      final item1 = items[0] as Map<String, dynamic>;
      expect(item1.containsKey('itemId'), true);
      expect(item1.containsKey('itemName'), true);
      expect(item1['itemId'], equals('1'));
      expect(item1['itemName'], equals('Item 1'));
    });

    test('toSupabaseJson handles lists', () {
      final freezedJson = {
        'userId': '123',
        'taskIds': ['task1', 'task2', 'task3'],
        'scheduledDates': [
          DateTime(2023, 1, 1, 12),
          DateTime(2023, 1, 2, 12),
        ],
        'items': [
          {'itemId': '1', 'itemName': 'Item 1'},
          {'itemId': '2', 'itemName': 'Item 2'},
        ],
      };

      final result = adapter.toSupabaseJson(freezedJson);
      
      expect(result['task_ids'], isA<List>());
      expect(result['task_ids'].length, equals(3));
      expect(result['task_ids'][0], equals('task1'));
      
      expect(result['scheduled_dates'], isA<List>());
      expect(result['scheduled_dates'][0], isA<String>());
      
      expect(result['items'], isA<List>());
      final items = result['items'] as List;
      expect(items.length, equals(2));
      
      final item1 = items[0] as Map<String, dynamic>;
      expect(item1.containsKey('item_id'), true);
      expect(item1.containsKey('item_name'), true);
      expect(item1['item_id'], equals('1'));
      expect(item1['item_name'], equals('Item 1'));
    });
    
    test('ignores internal Freezed fields when converting to Supabase format', () {
      final freezedJson = {
        'userId': '123',
        'name': 'John',
        '_\$hash': 12345,
        'runtimeType': 'SomeType',
        '_\$UserCopyWith': {},
      };

      final result = adapter.toSupabaseJson(freezedJson);

      expect(result.containsKey('user_id'), true);
      expect(result.containsKey('name'), true);
      
      // Should not include internal fields
      expect(result.containsKey('_\$hash'), false);
      expect(result.containsKey('runtimeType'), false);
      expect(result.containsKey('_\$UserCopyWith'), false);
    });
  });
} 