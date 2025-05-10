import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Provider for the UserRepository
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return UserRepository();
});

/// Provider for the TaskRepository
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  return TaskRepository();
});

// Add these providers once their repositories are implemented
/*
/// Provider for the ProjectRepository
final projectRepositoryProvider = Provider<IProjectRepository>((ref) {
  return ProjectRepository();
});

/// Provider for the SessionRepository
final sessionRepositoryProvider = Provider<ISessionRepository>((ref) {
  return SessionRepository();
});

/// Provider for the RoomRepository
final roomRepositoryProvider = Provider<IRoomRepository>((ref) {
  return RoomRepository();
});

/// Provider for the LogbookRepository
final logbookRepositoryProvider = Provider<ILogbookRepository>((ref) {
  return LogbookRepository();
});
*/ 