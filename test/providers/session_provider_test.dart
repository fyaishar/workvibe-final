import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finalworkvibe/core/models/session_info.dart';
import 'package:finalworkvibe/core/models/user_status.dart';
import 'package:finalworkvibe/core/providers/session_provider.dart';

void main() {
  group('SessionNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should be null', () {
      final sessionState = container.read(sessionNotifierProvider);
      expect(sessionState, isNull);
      expect(container.read(isLoggedInProvider), isFalse);
      expect(container.read(currentUserStatusProvider), isNull);
    });

    test('updateSession should update the state', () {
      final session = SessionInfo(
        id: '123',
        username: 'testUser',
        avatarUrl: 'https://example.com/avatar.jpg',
        status: UserStatus.active,
        lastUpdated: DateTime.now(),
      );

      container.read(sessionNotifierProvider.notifier).updateSession(session);

      final updatedState = container.read(sessionNotifierProvider);
      expect(updatedState, equals(session));
      expect(container.read(isLoggedInProvider), isTrue);
      expect(container.read(currentUserStatusProvider), equals(UserStatus.active));
    });

    test('updateStatus should modify only the status and timestamp', () {
      final now = DateTime.now();
      final session = SessionInfo(
        id: '123',
        username: 'testUser',
        avatarUrl: 'https://example.com/avatar.jpg',
        status: UserStatus.active,
        lastUpdated: now,
      );

      // Set initial session
      container.read(sessionNotifierProvider.notifier).updateSession(session);

      // Update status
      container.read(sessionNotifierProvider.notifier).updateStatus(
        UserStatus.paused,
        statusMessage: 'Taking a break',
      );

      final updatedState = container.read(sessionNotifierProvider);
      expect(updatedState?.id, equals('123'));
      expect(updatedState?.username, equals('testUser'));
      expect(updatedState?.status, equals(UserStatus.paused));
      expect(updatedState?.statusMessage, equals('Taking a break'));
      expect(updatedState?.lastUpdated.isAfter(now), isTrue);
    });

    test('clearSession should reset the state to null', () {
      // Set initial session
      final session = SessionInfo(
        id: '123',
        username: 'testUser',
        avatarUrl: 'https://example.com/avatar.jpg',
        status: UserStatus.active,
        lastUpdated: DateTime.now(),
      );
      container.read(sessionNotifierProvider.notifier).updateSession(session);

      // Clear session
      container.read(sessionNotifierProvider.notifier).clearSession();

      expect(container.read(sessionNotifierProvider), isNull);
      expect(container.read(isLoggedInProvider), isFalse);
      expect(container.read(currentUserStatusProvider), isNull);
    });

    test('updateStatus should do nothing when session is null', () {
      container.read(sessionNotifierProvider.notifier).updateStatus(
        UserStatus.paused,
        statusMessage: 'Should not be set',
      );

      expect(container.read(sessionNotifierProvider), isNull);
      expect(container.read(currentUserStatusProvider), isNull);
    });
  });
} 