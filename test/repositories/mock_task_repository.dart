import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../mocks/mock_models.dart';
import '../mocks/mock_supabase.dart';
import 'mock_repository_interface.dart';

/// A test implementation of the MockTaskRepository for testing
class TestTaskRepository implements MockTaskRepository {
  final MockSupabaseClient _client;
  
  TestTaskRepository(this._client);
  
  final String _tableName = 'tasks';
  
  @override
  Future<MockTask> create(MockTask entity) async {
    final result = await _client.from(_tableName)
        .insert(entity.toJson())
        .select()
        .single();
    
    return MockTask.fromJson(result);
  }
  
  @override
  Future<bool> delete(String id) async {
    await _client.from(_tableName)
        .delete()
        .eq('id', id);
    
    return true;
  }
  
  @override
  Future<List<MockTask>> executeQuery(String query, {Map<String, dynamic>? params}) async {
    // Simplified implementation for tests
    if (query == 'get_tasks_by_status') {
      final statusValues = params?['status_values'] as List<String>;
      
      // In a real implementation, this would call an RPC function
      // For tests, we simulate by filtering the data directly
      final result = await _client.from(_tableName)
          .select();
      
      return (result as List<dynamic>)
          .where((item) => statusValues.contains(item['status']))
          .map((item) => MockTask.fromJson(item))
          .toList();
    }
    
    if (query == 'get_overdue_tasks') {
      final currentDate = params?['current_date'] as String;
      
      // Simple filtering for overdue tasks
      final result = await _client.from(_tableName)
          .select();
      
      return (result as List<dynamic>)
          .where((item) => 
            item['due_date'] != null && 
            DateTime.parse(item['due_date'] as String).isBefore(DateTime.parse(currentDate)) &&
            item['status'] != 'completed')
          .map((item) => MockTask.fromJson(item))
          .toList();
    }
    
    if (query == 'get_tasks_due_within_days') {
      final currentDate = params?['current_date'] as String;
      final futureDate = params?['future_date'] as String;
      
      // Simple filtering for tasks due within a date range
      final result = await _client.from(_tableName)
          .select();
      
      return (result as List<dynamic>)
          .where((item) => 
            item['due_date'] != null && 
            !DateTime.parse(item['due_date'] as String).isBefore(DateTime.parse(currentDate)) &&
            !DateTime.parse(item['due_date'] as String).isAfter(DateTime.parse(futureDate)))
          .map((item) => MockTask.fromJson(item))
          .toList();
    }
    
    return [];
  }
  
  @override
  Future<List<MockTask>> getAll() async {
    final result = await _client.from(_tableName)
        .select();
    
    return (result as List<dynamic>)
        .map((item) => MockTask.fromJson(item))
        .toList();
  }
  
  @override
  Future<MockTask?> getById(String id) async {
    try {
      final result = await _client.from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return MockTask.fromJson(result);
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
  Future<List<MockTask>> query(Map<String, dynamic> queryParams) async {
    var query = _client.from(_tableName).select();
    
    // Apply filters
    queryParams.forEach((field, value) {
      query = query.eq(field, value);
    });
    
    final result = await query;
    
    return (result as List<dynamic>)
        .map((item) => MockTask.fromJson(item))
        .toList();
  }
  
  @override
  Stream<List<MockTask>> subscribe() {
    final controller = StreamController<List<MockTask>>();
    
    // Initial load
    getAll().then((tasks) {
      if (!controller.isClosed) {
        controller.add(tasks);
      }
    });
    
    // Set up subscription
    final channel = _client.channel('public:$_tableName');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _tableName,
      callback: (payload) async {
        // Reload all tasks when anything changes
        final tasks = await getAll();
        if (!controller.isClosed) {
          controller.add(tasks);
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
  Stream<MockTask?> subscribeToId(String id) {
    final controller = StreamController<MockTask?>();
    
    // Initial load
    getById(id).then((task) {
      if (!controller.isClosed) {
        controller.add(task);
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
          final task = await getById(id);
          if (!controller.isClosed) {
            controller.add(task);
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
  Future<MockTask> update(MockTask entity) async {
    final result = await _client.from(_tableName)
        .update(entity.toJson())
        .eq('id', entity.id)
        .select()
        .single();
    
    return MockTask.fromJson(result);
  }
  
  @override
  Future<bool> assignTask(String taskId, String userId) async {
    await _client
        .from(_tableName)
        .update({
          'assigned_to': userId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', taskId);
    
    return true;
  }
  
  @override
  Future<List<MockTask>> getOverdueTasks() async {
    final now = DateTime.now().toIso8601String();
    
    return await executeQuery(
      'get_overdue_tasks',
      params: {'current_date': now},
    );
  }
  
  @override
  Stream<List<MockTask>> getProjectTasksStream(String projectId) {
    final controller = StreamController<List<MockTask>>();
    
    // Initial load
    getTasksByProject(projectId).then((tasks) {
      if (!controller.isClosed) {
        controller.add(tasks);
      }
    });
    
    // Set up subscription
    final channel = _client.channel('public:$_tableName:project_$projectId');
    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'project_id',
      value: projectId,
    );
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _tableName,
      filter: filter,
      callback: (payload) async {
        // Reload all tasks for this project when anything changes
        final tasks = await getTasksByProject(projectId);
        if (!controller.isClosed) {
          controller.add(tasks);
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
  Future<List<MockTask>> getTasksByAssignee(String userId) async {
    return await query({'assigned_to': userId});
  }
  
  @override
  Future<List<MockTask>> getTasksByProject(String projectId) async {
    return await query({'project_id': projectId});
  }
  
  @override
  Future<List<MockTask>> getTasksByStatus(List<String> statuses) async {
    return await executeQuery(
      'get_tasks_by_status',
      params: {'status_values': statuses},
    );
  }
  
  @override
  Future<List<MockTask>> getTasksDueWithinDays(int days) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days)).toIso8601String();
    final currentDate = now.toIso8601String();
    
    return await executeQuery(
      'get_tasks_due_within_days',
      params: {
        'current_date': currentDate,
        'future_date': futureDate,
      },
    );
  }
  
  @override
  Future<bool> updateTaskStatus(String taskId, String status) async {
    await _client
        .from(_tableName)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', taskId);
    
    return true;
  }
} 