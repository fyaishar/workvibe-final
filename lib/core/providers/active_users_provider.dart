import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/session_info.dart';
import '../models/user_status.dart';

part 'active_users_provider.g.dart';

/// Notifier class for managing the list of active users in the system
@riverpod
class ActiveUsersNotifier extends _$ActiveUsersNotifier {
  /// Initialize with an empty list of users
  @override
  List<SessionInfo> build() => [];

  /// Add or update a user in the active users list
  void upsertUser(SessionInfo user) {
    state = [
      ...state.where((u) => u.id != user.id),
      user,
    ]..sort((a, b) => a.username.compareTo(b.username));
  }

  /// Remove a user from the active users list
  void removeUser(String userId) {
    state = state.where((user) => user.id != userId).toList();
  }

  /// Update a user's status
  void updateUserStatus(String userId, UserStatus newStatus, {String? statusMessage}) {
    state = state.map((user) {
      if (user.id == userId) {
        return user.copyWith(
          status: newStatus,
          statusMessage: statusMessage,
          lastUpdated: DateTime.now(),
        );
      }
      return user;
    }).toList();
  }

  /// Get all users with a specific status
  List<SessionInfo> getUsersByStatus(UserStatus status) {
    return state.where((user) => user.status == status).toList();
  }

  /// Clear all users from the list
  void clearUsers() {
    state = [];
  }
}

/// Provider for all active users
@riverpod
List<SessionInfo> activeUsers(ActiveUsersRef ref) {
  return ref.watch(activeUsersNotifierProvider);
}

/// Provider for online users only
@riverpod
List<SessionInfo> onlineUsers(OnlineUsersRef ref) {
  return ref.watch(activeUsersNotifierProvider)
    .where((user) => user.status == UserStatus.active)
    .toList();
}

/// Provider for users in focus mode
@riverpod
List<SessionInfo> focusingUsers(FocusingUsersRef ref) {
  return ref.watch(activeUsersNotifierProvider)
    .where((user) => user.status == UserStatus.focusing)
    .toList();
}

/// Provider for users in meetings
@riverpod
List<SessionInfo> inMeetingUsers(InMeetingUsersRef ref) {
  return ref.watch(activeUsersNotifierProvider)
    .where((user) => user.status == UserStatus.inMeeting)
    .toList();
}

/// Provider for away users
@riverpod
List<SessionInfo> awayUsers(AwayUsersRef ref) {
  return ref.watch(activeUsersNotifierProvider)
    .where((user) => user.status == UserStatus.away)
    .toList();
} 