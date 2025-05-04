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
      final updatedUser = user.copyWith(status: UserStatus.focusing);

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(user);
      notifier.upsertUser(updatedUser);

      final users = container.read(activeUsersProvider);
      expect(users.length, 1);
      expect(users.first.status, UserStatus.focusing);
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
      notifier.updateUserStatus('1', UserStatus.focusing, statusMessage: 'Focus time');

      final updatedUser = container.read(activeUsersProvider).first;
      expect(updatedUser.status, UserStatus.focusing);
      expect(updatedUser.statusMessage, 'Focus time');
      expect(updatedUser.lastUpdated.isAfter(beforeUpdate), isTrue);
      expect(updatedUser.username, user.username); // Other fields unchanged
    });

    test('filtered providers should return correct users', () {
      final activeUser = createUser(id: '1', username: 'Alice', status: UserStatus.active);
      final focusingUser = createUser(id: '2', username: 'Bob', status: UserStatus.focusing);
      final awayUser = createUser(id: '3', username: 'Charlie', status: UserStatus.away);
      final meetingUser = createUser(id: '4', username: 'David', status: UserStatus.inMeeting);

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(activeUser);
      notifier.upsertUser(focusingUser);
      notifier.upsertUser(awayUser);
      notifier.upsertUser(meetingUser);

      expect(container.read(onlineUsersProvider).length, 1);
      expect(container.read(onlineUsersProvider).first.id, '1');

      expect(container.read(focusingUsersProvider).length, 1);
      expect(container.read(focusingUsersProvider).first.id, '2');

      expect(container.read(awayUsersProvider).length, 1);
      expect(container.read(awayUsersProvider).first.id, '3');

      expect(container.read(inMeetingUsersProvider).length, 1);
      expect(container.read(inMeetingUsersProvider).first.id, '4');
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
      final focusingUser1 = createUser(id: '2', username: 'Bob', status: UserStatus.focusing);
      final focusingUser2 = createUser(id: '3', username: 'Charlie', status: UserStatus.focusing);

      final notifier = container.read(activeUsersNotifierProvider.notifier);
      notifier.upsertUser(activeUser);
      notifier.upsertUser(focusingUser1);
      notifier.upsertUser(focusingUser2);

      final focusingUsers = notifier.getUsersByStatus(UserStatus.focusing);
      expect(focusingUsers.length, 2);
      expect(focusingUsers.every((u) => u.status == UserStatus.focusing), isTrue);
    });
  });
} 