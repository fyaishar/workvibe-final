import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../models/user.dart';
import '../../models/user_status.dart';
import '../../models/exceptions/repository_exception.dart';
import '../../../services/error/logging_service.dart';
import '../../../services/error/supabase_error_handler.dart';
import 'base_repository.dart';
import '../interfaces/user_repository_interface.dart';

/// Implementation of [IUserRepository] using Supabase as backend.
class UserRepository extends SupabaseRepository<User> implements IUserRepository {
  // Get the SupabaseClient instance
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get logging service for error reporting
  final LoggingService _logger = LoggingService();
  
  /// The name of the Supabase table that holds users
  @override
  String get tableName => 'users';
  
  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);
  
  @override
  Map<String, dynamic> toJson(User entity) => entity.toJson();
  
  @override
  String getIdFromEntity(User entity) => entity.id;

  // Override with explicit User type for type safety
  @override
  Future<User?> getById(String id) => super.getById(id);

  @override
  Future<List<User>> getAll() => super.getAll();

  @override
  Future<List<User>> query(Map<String, dynamic> queryParams) => super.query(queryParams);

  @override
  Future<User> create(User entity) => super.create(entity);

  @override
  Future<User> update(User entity) => super.update(entity);

  @override
  Future<List<User>> executeQuery(String query, {Map<String, dynamic>? params}) => 
      super.executeQuery(query, params: params);

  @override
  Stream<List<User>> subscribe() => super.subscribe();

  @override
  Stream<User?> subscribeToId(String id) => super.subscribeToId(id);
  
  @override
  Future<User?> getUserByEmail(String email) async {
    final results = await query({'email': email});
    return results.isEmpty ? null : results.first;
  }
  
  @override
  Future<List<User>> getUsersByStatus(List<String> statuses) async {
    // Convert string statuses to the actual UserStatus enum values
    final statusValues = statuses.map((s) => s.toLowerCase()).toList();
    
    // We need to make a custom query for this since it's an array operation
    final result = await executeQuery(
      'get_users_by_status',
      params: {'status_values': statusValues},
    );
    
    return result;
  }
  
  @override
  Future<List<User>> searchUsers(String searchTerm) async {
    // We'll use a custom stored procedure for searching
    // This would typically use Postgres text search capabilities
    final result = await executeQuery(
      'search_users',
      params: {'search_term': searchTerm},
    );
    
    return result;
  }
  
  @override
  Future<bool> updateUserStatus(String userId, String status, {String? statusMessage}) async {
    try {
      // Validate the status value against enum
      final userStatus = _validateUserStatus(status);
      
      // Update the user record with new status
      final updateData = {
        'status': userStatus.toJson(),
        if (statusMessage != null) 'status_message': statusMessage,
        'updated_at': DateTime.now().toIso8601String()
      };
      
      await _supabase
          .from(tableName)
          .update(updateData)
          .eq(primaryKeyField, userId);
      
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update user status',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'userId': userId,
          'status': status,
          'statusMessage': statusMessage
        },
      );
      
      throw RepositoryException(
        operation: 'updateUserStatus',
        message: 'Failed to update status for user $userId',
        originalError: e,
      );
    }
  }
  
  @override
  Stream<List<User>> getActiveUsersStream() {
    // Create a stream controller
    final controller = StreamController<List<User>>();
    
    // Set up the filtering query for active users
    final activeStatuses = [UserStatus.active.toJson()];
    
    // Initial fetch of active users
    getUsersByStatus(activeStatuses)
      .then((users) {
        if (!controller.isClosed) {
          controller.add(users);
        }
      })
      .catchError((e) {
        _logger.error(
          'Error fetching initial active users',
          category: LogCategory.realtime,
          error: e,
        );
        
        if (!controller.isClosed) {
          controller.add([]);
        }
      });
    
    // Set up a real-time subscription that filters for active users
    final channelName = 'public:users:active';
    final channel = _supabase.channel(channelName);
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: tableName,
      callback: (payload) async {
        try {
          // When any user changes, refetch active users
          final updatedUsers = await getUsersByStatus(activeStatuses);
          
          if (!controller.isClosed) {
            controller.add(updatedUsers);
          }
        } catch (e) {
          _logger.error(
            'Error handling active users update',
            category: LogCategory.realtime,
            error: e,
          );
        }
      },
    ).subscribe();
    
    // Clean up when the stream is canceled
    controller.onCancel = () {
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }
  
  // Helper method to validate user status
  UserStatus _validateUserStatus(String status) {
    // Try to convert string to enum value
    try {
      // Use the fromJson method from the UserStatus enum
      return UserStatus.fromJson(status.toLowerCase());
    } catch (e) {
      // If conversion fails, throw a more specific exception
      throw RepositoryException(
        operation: 'validateUserStatus',
        message: 'Invalid user status: $status',
        originalError: e,
      );
    }
  }
} 