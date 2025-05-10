import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'dart:async';

import '../repositories/implementations/user_repository.dart';
import '../repositories/interfaces/user_repository_interface.dart';
import '../repositories/implementations/task_repository.dart';
import '../repositories/interfaces/task_repository_interface.dart';

// Import these once they're implemented
// import '../repositories/implementations/project_repository.dart';
// import '../repositories/interfaces/project_repository_interface.dart';
// import '../repositories/implementations/session_repository.dart';
// import '../repositories/interfaces/session_repository_interface.dart';
// import '../repositories/implementations/room_repository.dart';
// import '../repositories/interfaces/room_repository_interface.dart';
// import '../repositories/implementations/logbook_repository.dart';
// import '../repositories/interfaces/logbook_repository_interface.dart';

import '../../features/auth/state/auth_state.dart';
import '../models/exceptions/repository_exceptions.dart';

/// A provider that watches auth state changes and rebuilds dependent providers
/// This allows repositories to refresh when auth state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  // Watch the auth provider to get current auth state
  final currentAuthState = ref.watch(authProvider);
  
  // Set up a stream that merges the current auth state with future changes
  final controller = StreamController<AuthState>();
  
  // Start with current state
  controller.add(currentAuthState);
  
  // Add subscription to auth changes
  final subscription = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    // Convert auth event to app AuthState
    if (event.session != null) {
      controller.add(AuthState(
        isAuthenticated: true,
        user: event.session?.user,
        session: event.session,
        isLoading: false,
        error: null,
      ));
    } else {
      controller.add(const AuthState(
        isAuthenticated: false,
        user: null,
        session: null,
        isLoading: false,
        error: null,
      ));
    }
  });
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });
  
  return controller.stream;
});

/// Handles repository errors consistently across all repositories
RepositoryException _handleRepositoryError(Object error, String operation) {
  // Already a RepositoryException, just return it
  if (error is RepositoryException) {
    return error;
  }
  
  // Convert other error types to RepositoryException
  String message;
  
  if (error is AuthException) {
    message = 'Authentication error: ${error.message}';
  } else if (error is PostgrestException) {
    message = 'Database error: ${error.message}';
  } else if (error.toString().contains('realtime') || error.toString().contains('subscription')) {
    message = 'Realtime error: ${error.toString()}';
  } else {
    message = 'Repository error: ${error.toString()}';
  }
  
  return RepositoryException(
    operation: operation,
    message: message,
    originalError: error,
  );
}

/// Provider for the UserRepository
/// This repository will be recreated when auth state changes
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  // Watch auth state changes to recreate repository when auth changes
  final authState = ref.watch(authStateChangesProvider);
  
  // Create the repository and handle errors
  try {
    return UserRepository();
  } catch (error) {
    throw _handleRepositoryError(
      error, 
      'Creating UserRepository'
    );
  }
});

/// Provider for the TaskRepository
/// This repository will be recreated when auth state changes
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  // Watch auth state changes to recreate repository when auth changes  
  final authState = ref.watch(authStateChangesProvider);
  
  // Create the repository and handle errors
  try {
    return TaskRepository();
  } catch (error) {
    throw _handleRepositoryError(
      error, 
      'Creating TaskRepository'
    );
  }
});

// Add these providers once their repositories are implemented
/*
/// Provider for the ProjectRepository
final projectRepositoryProvider = Provider<IProjectRepository>((ref) {
  // Watch auth state changes to recreate repository when auth changes
  final authState = ref.watch(authStateChangesProvider);
  
  // Create the repository and handle errors
  try {
    return ProjectRepository();
  } catch (error) {
    throw _handleRepositoryError(
      error, 
      'Creating ProjectRepository'
    );
  }
});

/// Provider for the SessionRepository
final sessionRepositoryProvider = Provider<ISessionRepository>((ref) {
  // Watch auth state changes to recreate repository when auth changes
  final authState = ref.watch(authStateChangesProvider);
  
  // Create the repository and handle errors
  try {
    return SessionRepository();
  } catch (error) {
    throw _handleRepositoryError(
      error, 
      'Creating SessionRepository'
    );
  }
});

/// Provider for the RoomRepository
final roomRepositoryProvider = Provider<IRoomRepository>((ref) {
  // Watch auth state changes to recreate repository when auth changes
  final authState = ref.watch(authStateChangesProvider);
  
  // Create the repository and handle errors
  try {
    return RoomRepository();
  } catch (error) {
    throw _handleRepositoryError(
      error, 
      'Creating RoomRepository'
    );
  }
});

/// Provider for the LogbookRepository
final logbookRepositoryProvider = Provider<ILogbookRepository>((ref) {
  // Watch auth state changes to recreate repository when auth changes
  final authState = ref.watch(authStateChangesProvider);
  
  // Create the repository and handle errors
  try {
    return LogbookRepository();
  } catch (error) {
    throw _handleRepositoryError(
      error, 
      'Creating LogbookRepository'
    );
  }
});
*/

/// Repository provider overrides for testing
class RepositoryOverrides {
  /// Creates a list of provider overrides for testing
  /// 
  /// This allows mocking repositories in tests by providing
  /// mock implementations of the repository interfaces.
  /// 
  /// Example:
  /// ```dart
  /// final mockUserRepo = MockUserRepository();
  /// final mockTaskRepo = MockTaskRepository();
  /// 
  /// await pumpApp(
  ///   tester,
  ///   const MyApp(),
  ///   overrides: [
  ///     ...RepositoryOverrides.getOverrides(
  ///       userRepository: mockUserRepo,
  ///       taskRepository: mockTaskRepo,
  ///     ),
  ///   ],
  /// );
  /// ```
  static List<Override> getOverrides({
    IUserRepository? userRepository,
    ITaskRepository? taskRepository,
  }) {
    return [
      if (userRepository != null)
        userRepositoryProvider.overrideWithValue(userRepository),
      if (taskRepository != null)
        taskRepositoryProvider.overrideWithValue(taskRepository),
      // Add these overrides once their repositories are implemented
      /*
      if (projectRepository != null)
        projectRepositoryProvider.overrideWithValue(projectRepository),
      if (sessionRepository != null)
        sessionRepositoryProvider.overrideWithValue(sessionRepository),
      if (roomRepository != null)
        roomRepositoryProvider.overrideWithValue(roomRepository),
      if (logbookRepository != null)
        logbookRepositoryProvider.overrideWithValue(logbookRepository),
      */
    ];
  }
} 