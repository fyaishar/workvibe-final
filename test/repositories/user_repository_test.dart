import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finalworkvibe/core/models/user_status.dart';
import '../mocks/mock_supabase.dart';
import '../mocks/mock_models.dart';
import 'mock_user_repository.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late TestUserRepository userRepository;

  const testUserId = 'test-user-1';
  final testUser = MockUser(
    id: testUserId,
    username: 'testuser',
    email: 'test@example.com',
    status: UserStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    // Setup mock client
    mockSupabaseClient = MockSupabaseClient();
    
    // Initialize repository with mock client
    userRepository = TestUserRepository(mockSupabaseClient);
    
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

  group('UserRepository', () {
    test('getById returns correct user', () async {
      final user = await userRepository.getById(testUserId);
      
      expect(user, isNotNull);
      expect(user?.id, equals(testUserId));
      expect(user?.username, equals('testuser'));
      expect(user?.email, equals('test@example.com'));
      expect(user?.status, equals(UserStatus.active));
    });
    
    test('getAll returns all users', () async {
      final users = await userRepository.getAll();
      
      expect(users.length, equals(2));
      expect(users.any((u) => u.id == testUserId), isTrue);
      expect(users.any((u) => u.username == 'idleuser'), isTrue);
    });
    
    test('create adds a new user', () async {
      final newUser = MockUser(
        id: 'new-user',
        username: 'newuser',
        email: 'new@example.com',
        status: UserStatus.paused,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final createdUser = await userRepository.create(newUser);
      
      expect(createdUser.id, equals('new-user'));
      expect(createdUser.username, equals('newuser'));
      expect(createdUser.email, equals('new@example.com'));
      
      // Verify user was added to database
      final users = await userRepository.getAll();
      expect(users.length, equals(3));
      expect(users.any((u) => u.id == 'new-user'), isTrue);
    });
    
    test('update modifies existing user', () async {
      final updatedUser = testUser.copyWith(
        username: 'updateduser',
        status: UserStatus.paused,
      );
      
      final result = await userRepository.update(updatedUser);
      
      expect(result.id, equals(testUserId));
      expect(result.username, equals('updateduser'));
      expect(result.status, equals(UserStatus.paused));
      
      // Verify user was updated in database
      final user = await userRepository.getById(testUserId);
      expect(user?.username, equals('updateduser'));
      expect(user?.status, equals(UserStatus.paused));
    });
    
    test('delete removes user', () async {
      final result = await userRepository.delete(testUserId);
      
      expect(result, isTrue);
      
      // Verify user was removed from database
      final user = await userRepository.getById(testUserId);
      expect(user, isNull);
      
      final users = await userRepository.getAll();
      expect(users.length, equals(1));
      expect(users.any((u) => u.id == testUserId), isFalse);
    });
    
    test('getUserByEmail returns correct user', () async {
      final user = await userRepository.getUserByEmail('test@example.com');
      
      expect(user, isNotNull);
      expect(user?.id, equals(testUserId));
      expect(user?.username, equals('testuser'));
    });
    
    test('getUsersByStatus returns users with matching status', () async {
      final activeUsers = await userRepository.getUsersByStatus(['active']);
      
      expect(activeUsers.length, equals(1));
      expect(activeUsers.first.id, equals(testUserId));
      expect(activeUsers.first.status, equals(UserStatus.active));
      
      final idleUsers = await userRepository.getUsersByStatus(['idle']);
      
      expect(idleUsers.length, equals(1));
      expect(idleUsers.first.username, equals('idleuser'));
      expect(idleUsers.first.status, equals(UserStatus.idle));
    });
    
    test('searchUsers finds users matching search term', () async {
      final results = await userRepository.searchUsers('test');
      
      expect(results.length, greaterThan(0));
      expect(results.any((u) => u.username == 'testuser'), isTrue);
    });
    
    test('updateUserStatus changes user status', () async {
      final result = await userRepository.updateUserStatus(
        testUserId, 
        'paused',
        statusMessage: 'Away for lunch',
      );
      
      expect(result, isTrue);
      
      // Verify status was updated
      final user = await userRepository.getById(testUserId);
      expect(user?.status, equals(UserStatus.paused));
      expect(user?.statusMessage, equals('Away for lunch'));
    });
    
    test('getActiveUsersStream emits active users', () async {
      // Set up a stream listener
      final stream = userRepository.getActiveUsersStream();
      
      // Get the first emitted value
      final activeUsers = await stream.first;
      
      expect(activeUsers.length, equals(1));
      expect(activeUsers.first.id, equals(testUserId));
      expect(activeUsers.first.status, equals(UserStatus.active));
      
      // Change user status to idle
      await userRepository.updateUserStatus(testUserId, 'idle');
      
      // Next emission should have no active users
      final updatedActiveUsers = await stream.first;
      expect(updatedActiveUsers.isEmpty, isTrue);
    });
    
    test('subscribe emits all users and updates on changes', () async {
      final stream = userRepository.subscribe();
      
      // Initial emission should contain all users
      final initialUsers = await stream.first;
      expect(initialUsers.length, equals(2));
      
      // Add a new user
      mockSupabaseClient.simulateInsert('users', {
        'id': 'test-user-3',
        'username': 'newuser',
        'email': 'new@example.com',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Next emission should include the new user
      final updatedUsers = await stream.first;
      expect(updatedUsers.length, equals(3));
      expect(updatedUsers.any((u) => u.id == 'test-user-3'), isTrue);
    });
    
    test('subscribeToId emits single user updates', () async {
      final stream = userRepository.subscribeToId(testUserId);
      
      // Initial emission should be the test user
      final initialUser = await stream.first;
      expect(initialUser?.id, equals(testUserId));
      
      // Update the user
      mockSupabaseClient.simulateUpdate('users', testUserId, {
        'id': testUserId,
        'username': 'updatedname',
        'email': 'test@example.com',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Next emission should have the updated user
      final updatedUser = await stream.first;
      expect(updatedUser?.username, equals('updatedname'));
      
      // Delete the user
      mockSupabaseClient.simulateDelete('users', testUserId);
      
      // Next emission should be null
      final finalUser = await stream.first;
      expect(finalUser, isNull);
    });
  });
} 