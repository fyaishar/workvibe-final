import '../../models/user.dart';
import 'base_repository.dart';

/// Interface for user-specific repository operations
abstract class IUserRepository extends IRepository<User> {
  /// Find a user by their email address
  Future<User?> getUserByEmail(String email);
  
  /// Get users that have one of the provided statuses
  Future<List<User>> getUsersByStatus(List<String> statuses);
  
  /// Search for users by name or email
  Future<List<User>> searchUsers(String searchTerm);
  
  /// Update a user's status and optional status message
  Future<bool> updateUserStatus(String userId, String status, {String? statusMessage});
  
  /// Get a real-time stream of active users
  Stream<List<User>> getActiveUsersStream();
} 