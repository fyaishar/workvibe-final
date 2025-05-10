import 'dart:async';
import 'package:finalworkvibe/core/models/user_status.dart';
import 'package:finalworkvibe/core/repositories/interfaces/user_repository_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../mocks/mock_models.dart';
import '../mocks/mock_supabase.dart';
import 'mock_repository_interface.dart';

/// A test implementation of the MockUserRepository for testing
class TestUserRepository implements MockUserRepository {
  final MockSupabaseClient _client;
  
  TestUserRepository(this._client);
  
  final String _tableName = 'users';
  
  @override
  Future<MockUser> create(MockUser entity) async {
    final result = await _client.from(_tableName)
        .insert(entity.toJson())
        .select()
        .single();
    
    return MockUser.fromJson(result);
  }
  
  @override
  Future<bool> delete(String id) async {
    await _client.from(_tableName)
        .delete()
        .eq('id', id);
    
    return true;
  }
  
  @override
  Future<List<MockUser>> executeQuery(String query, {Map<String, dynamic>? params}) async {
    // Simplified implementation for tests
    if (query == 'get_users_by_status') {
      final statusValues = params?['status_values'] as List<String>;
      
      // In a real implementation, this would call an RPC function
      // For tests, we simulate by filtering the data directly
      final result = await _client.from(_tableName)
          .select();
      
      return (result as List<dynamic>)
          .where((item) => statusValues.contains(item['status']))
          .map((item) => MockUser.fromJson(item))
          .toList();
    }
    
    if (query == 'search_users') {
      final searchTerm = params?['search_term'] as String;
      
      // Simple search simulation
      final result = await _client.from(_tableName)
          .select();
      
      return (result as List<dynamic>)
          .where((item) => 
            (item['username'] as String).contains(searchTerm) || 
            (item['email'] as String).contains(searchTerm))
          .map((item) => MockUser.fromJson(item))
          .toList();
    }
    
    return [];
  }
  
  @override
  Future<List<MockUser>> getAll() async {
    final result = await _client.from(_tableName)
        .select();
    
    return (result as List<dynamic>)
        .map((item) => MockUser.fromJson(item))
        .toList();
  }
  
  @override
  Future<MockUser?> getById(String id) async {
    try {
      final result = await _client.from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return MockUser.fromJson(result);
    } catch (e) {
      // Return null if not found
      if (e.toString().contains('not found') || 
          e.toString().contains('no rows returned')) {
        return null;
      }
      rethrow;
    }
  }
  
  @override
  Stream<List<MockUser>> getActiveUsersStream() {
    // For testing, we'll return a stream that emits a filtered list of users
    final controller = StreamController<List<MockUser>>();
    
    // Set up a listener for table changes
    final channel = _client.channel('public:users');
    
    // Initial load
    getUsersByStatus(['active']).then((users) {
      if (!controller.isClosed) {
        controller.add(users);
      }
    });
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _tableName,
      callback: (payload) async {
        // Reload active users when anything changes
        final activeUsers = await getUsersByStatus(['active']);
        if (!controller.isClosed) {
          controller.add(activeUsers);
        }
      },
    ).subscribe();
    
    // Cleanup
    controller.onCancel = () {
      _client.removeChannel(channel);
    };
    
    return controller.stream;
  }
  
  @override
  Future<MockUser?> getUserByEmail(String email) async {
    final results = await query({'email': email});
    return results.isEmpty ? null : results.first;
  }
  
  @override
  Future<List<MockUser>> getUsersByStatus(List<String> statuses) async {
    return await executeQuery(
      'get_users_by_status',
      params: {'status_values': statuses},
    );
  }
  
  @override
  Future<List<MockUser>> query(Map<String, dynamic> queryParams) async {
    var query = _client.from(_tableName).select();
    
    // Apply filters
    queryParams.forEach((field, value) {
      query = query.eq(field, value);
    });
    
    final result = await query;
    
    return (result as List<dynamic>)
        .map((item) => MockUser.fromJson(item))
        .toList();
  }
  
  @override
  Future<List<MockUser>> searchUsers(String searchTerm) async {
    return await executeQuery(
      'search_users',
      params: {'search_term': searchTerm},
    );
  }
  
  @override
  Stream<List<MockUser>> subscribe() {
    final controller = StreamController<List<MockUser>>();
    
    // Initial load
    getAll().then((users) {
      if (!controller.isClosed) {
        controller.add(users);
      }
    });
    
    // Set up subscription
    final channel = _client.channel('public:$_tableName');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _tableName,
      callback: (payload) async {
        // Reload all users when anything changes
        final users = await getAll();
        if (!controller.isClosed) {
          controller.add(users);
        }
      },
    ).subscribe();
    
    // Cleanup
    controller.onCancel = () {
      _client.removeChannel(channel);
    };
    
    return controller.stream;
  }
  
  @override
  Stream<MockUser?> subscribeToId(String id) {
    final controller = StreamController<MockUser?>();
    
    // Initial load
    getById(id).then((user) {
      if (!controller.isClosed) {
        controller.add(user);
      }
    });
    
    // Set up subscription
    final channel = _client.channel('public:$_tableName:id_$id');
    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'id',
      value: id,
    );
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _tableName,
      filter: filter,
      callback: (payload) async {
        if (payload.eventType == PostgresChangeEvent.delete) {
          // Entity was deleted
          if (!controller.isClosed) {
            controller.add(null);
          }
        } else {
          // Entity was updated, reload it
          final user = await getById(id);
          if (!controller.isClosed) {
            controller.add(user);
          }
        }
      },
    ).subscribe();
    
    // Cleanup
    controller.onCancel = () {
      _client.removeChannel(channel);
    };
    
    return controller.stream;
  }
  
  @override
  Future<MockUser> update(MockUser entity) async {
    final result = await _client.from(_tableName)
        .update(entity.toJson())
        .eq('id', entity.id)
        .select()
        .single();
    
    return MockUser.fromJson(result);
  }
  
  @override
  Future<bool> updateUserStatus(String userId, String status, {String? statusMessage}) async {
    final updateData = {
      'status': status,
      if (statusMessage != null) 'status_message': statusMessage,
      'updated_at': DateTime.now().toIso8601String()
    };
    
    await _client
        .from(_tableName)
        .update(updateData)
        .eq('id', userId);
    
    return true;
  }
} 