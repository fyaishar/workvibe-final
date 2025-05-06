import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finalworkvibe/core/models/session_info.dart';
import 'package:finalworkvibe/core/models/user_status.dart';
import 'package:finalworkvibe/core/providers/active_users_provider.dart';

void main() {
  group('ActiveUsersNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    SessionInfo createUser({
      required String id,
      required String username,
      UserStatus status = UserStatus.active,
    }) {
      return SessionInfo(
        id: id,
        username: username,
        avatarUrl: 'https://example.com/avatar.jpg',
        status: status,
        lastUpdated: DateTime.now(),
      );
    }

    test('Initial state should be empty list', () {
      final users = container.read(activeUsersProvider);
      expect(users, isEmpty);
    });

    test('upsertUser should add new user and sort by username', () {
      final user1 = createUser(id: '1', username: 'Bob');
      final user2 = createUser(id: '2', username: 'Alice');

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(user1);
      notifier.upsertUser(user2);

      final users = container.read(activeUsersProvider);
      expect(users.length, 2);
      expect(users[0].username, 'Alice'); // Should be sorted
      expect(users[1].username, 'Bob');
    });

    test('upsertUser should update existing user', () {
      final user = createUser(id: '1', username: 'Alice');
      final updatedUser = user.copyWith(status: UserStatus.paused);

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(user);
      notifier.upsertUser(updatedUser);

      final users = container.read(activeUsersProvider);
      expect(users.length, 1);
      expect(users.first.status, UserStatus.paused);
    });

    test('removeUser should remove user by ID', () {
      final user1 = createUser(id: '1', username: 'Alice');
      final user2 = createUser(id: '2', username: 'Bob');

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(user1);
      notifier.upsertUser(user2);
      notifier.removeUser('1');

      final users = container.read(activeUsersProvider);
      expect(users.length, 1);
      expect(users.first.id, '2');
    });

    test('updateUserStatus should update only status and timestamp', () {
      final user = createUser(id: '1', username: 'Alice');
      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(user);

      final beforeUpdate = DateTime.now();
      notifier.updateUserStatus('1', UserStatus.paused, statusMessage: 'Taking a break');

      final updatedUser = container.read(activeUsersProvider).first;
      expect(updatedUser.status, UserStatus.paused);
      expect(updatedUser.statusMessage, 'Taking a break');
      expect(updatedUser.lastUpdated.isAfter(beforeUpdate), isTrue);
      expect(updatedUser.username, user.username); // Other fields unchanged
    });

    test('online users provider should return active users', () {
      final activeUser = createUser(id: '1', username: 'Alice', status: UserStatus.active);
      final pausedUser = createUser(id: '2', username: 'Bob', status: UserStatus.paused);
      final idleUser = createUser(id: '3', username: 'Charlie', status: UserStatus.idle);

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(activeUser);
      notifier.upsertUser(pausedUser);
      notifier.upsertUser(idleUser);

      expect(container.read(onlineUsersProvider).length, 1);
      expect(container.read(onlineUsersProvider).first.id, '1');
    });

    test('clearUsers should remove all users', () {
      final user1 = createUser(id: '1', username: 'Alice');
      final user2 = createUser(id: '2', username: 'Bob');

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(user1);
      notifier.upsertUser(user2);
      notifier.clearUsers();

      expect(container.read(activeUsersProvider), isEmpty);
    });

    test('getUsersByStatus should return filtered users', () {
      final activeUser = createUser(id: '1', username: 'Alice', status: UserStatus.active);
      final pausedUser1 = createUser(id: '2', username: 'Bob', status: UserStatus.paused);
      final pausedUser2 = createUser(id: '3', username: 'Charlie', status: UserStatus.paused);

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(activeUser);
      notifier.upsertUser(pausedUser1);
      notifier.upsertUser(pausedUser2);

      final pausedUsers = notifier.getUsersByStatus(UserStatus.paused);
      expect(pausedUsers.length, 2);
      expect(pausedUsers.every((u) => u.status == UserStatus.paused), isTrue);
    });
  });
} 