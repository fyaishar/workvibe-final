import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/session_info.dart';
import '../models/user_status.dart';

part 'session_provider.g.dart';

/// Notifier class for managing the current user's session state
@riverpod
class SessionNotifier extends _$SessionNotifier {
  /// Initialize the session state as null (not logged in)
  @override
  SessionInfo? build() => null;

  /// Update the current session with new information
  void updateSession(SessionInfo session) {
    state = session;
  }

  /// Update the user's status
  void updateStatus(UserStatus newStatus, {String? statusMessage}) {
    if (state == null) return;
    
    state = state!.copyWith(
      status: newStatus,
      statusMessage: statusMessage,
      lastUpdated: DateTime.now(),
    );
  }

  /// Clear the session (logout)
  void clearSession() {
    state = null;
  }

  /// Check if the user is logged in
  bool get isLoggedIn => state != null;
}

/// Provider for the current user's session information
@riverpod
SessionInfo? currentSession(CurrentSessionRef ref) {
  return ref.watch(sessionNotifierProvider);
}

/// Provider that exposes whether the user is currently logged in
@riverpod
bool isLoggedIn(IsLoggedInRef ref) {
  return ref.watch(sessionNotifierProvider.notifier).isLoggedIn;
}

/// Provider that exposes the current user's status
@riverpod
UserStatus? currentUserStatus(CurrentUserStatusRef ref) {
  final session = ref.watch(sessionNotifierProvider);
  return session?.status;
} 