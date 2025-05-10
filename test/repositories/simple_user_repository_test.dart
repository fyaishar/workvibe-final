import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_models.dart';
import '../mocks/mock_supabase.dart';
import 'package:finalworkvibe/core/models/user_status.dart';

// Simple enum for PostgresChangeEvent for testing
enum PostgresChangeEvent {
  insert,
  update,
  delete,
  all,
}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  
  const testUserId = 'test-user-1';
  
  setUp(() {
    // Setup mock client
    mockSupabaseClient = MockSupabaseClient();
    
    // Seed mock database with test users
    mockSupabaseClient.simulateInsert('users', {
      'id': testUserId,
      'username': 'testuser',
      'email': 'test@example.com',
      'status': 'active',
      'avatar_url': 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    mockSupabaseClient.simulateInsert('users', {
      'id': 'test-user-2',
      'username': 'idleuser',
      'email': 'idle@example.com',
      'status': 'idle',
      'avatar_url': 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  });

  group('MockSupabaseClient', () {
    test('get returns correct data', () async {
      final result = await mockSupabaseClient.from('users').select().eq('id', testUserId).single();
      
      expect(result, isNotNull);
      expect(result['id'], equals(testUserId));
      expect(result['username'], equals('testuser'));
      expect(result['email'], equals('test@example.com'));
      expect(result['status'], equals('active'));
    });
    
    test('getAll returns all data', () async {
      final result = await mockSupabaseClient.from('users').select();
      
      expect(result, isA<List>());
      expect(result.length, equals(2));
      expect(result.any((r) => r['id'] == testUserId), isTrue);
      expect(result.any((r) => r['username'] == 'idleuser'), isTrue);
    });
    
    test('add inserts a new record', () async {
      final newUserId = 'test-user-3';
      final result = await mockSupabaseClient.from('users').insert({
        'id': newUserId,
        'username': 'newuser',
        'email': 'new@example.com',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();
      
      expect(result, isNotNull);
      expect(result['id'], equals(newUserId));
      expect(result['username'], equals('newuser'));
      
      // Verify user was added
      final allUsers = await mockSupabaseClient.from('users').select();
      expect(allUsers.length, equals(3));
      expect(allUsers.any((r) => r['id'] == newUserId), isTrue);
    });
    
    test('update modifies a record', () async {
      final result = await mockSupabaseClient.from('users')
          .update({
            'username': 'updateduser',
            'status': 'paused',
          })
          .eq('id', testUserId)
          .select()
          .single();
      
      expect(result, isNotNull);
      expect(result['username'], equals('updateduser'));
      expect(result['status'], equals('paused'));
      
      // Verify user was updated
      final user = await mockSupabaseClient.from('users').select().eq('id', testUserId).single();
      expect(user['username'], equals('updateduser'));
      expect(user['status'], equals('paused'));
    });
    
    test('delete removes a record', () async {
      final result = await mockSupabaseClient.from('users').delete().eq('id', testUserId);
      
      // Verify user was removed
      final allUsers = await mockSupabaseClient.from('users').select();
      expect(allUsers.length, equals(1));
      expect(allUsers.any((r) => r['id'] == testUserId), isFalse);
    });
    
    test('simulateUpdate triggers realtime subscription', () async {
      // Set up a realtime subscription
      var callbackCalled = false;
      
      final channel = mockSupabaseClient.channel('public:users');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'users',
        callback: (payload) {
          callbackCalled = true;
          expect(payload.eventType, equals(PostgresChangeEvent.update));
          expect(payload.table, equals('users'));
          expect(payload.new_record?['username'], equals('updatedname'));
        },
      ).subscribe();
      
      // Simulate an update
      mockSupabaseClient.simulateUpdate('users', testUserId, {
        'id': testUserId,
        'username': 'updatedname',
        'email': 'test@example.com',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Verify callback was called
      expect(callbackCalled, isTrue);
    });
    
    test('simulateDelete triggers realtime subscription', () async {
      // Set up a realtime subscription
      var callbackCalled = false;
      
      final channel = mockSupabaseClient.channel('public:users');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'users',
        callback: (payload) {
          callbackCalled = true;
          expect(payload.eventType, equals(PostgresChangeEvent.delete));
          expect(payload.table, equals('users'));
          expect(payload.old_record?['id'], equals(testUserId));
        },
      ).subscribe();
      
      // Simulate a deletion
      mockSupabaseClient.simulateDelete('users', testUserId);
      
      // Verify callback was called
      expect(callbackCalled, isTrue);
    });
  });
} 