import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/task.dart';
import '../../models/exceptions/repository_exception.dart';
import '../../../services/error/logging_service.dart';
import 'base_repository.dart';
import '../interfaces/task_repository_interface.dart';

/// Implementation of [ITaskRepository] using Supabase as backend.
class TaskRepository extends SupabaseRepository<Task> implements ITaskRepository {
  // Get the SupabaseClient instance
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get logging service for error reporting
  final LoggingService _logger = LoggingService();
  
  /// The name of the Supabase table that holds tasks
  @override
  String get tableName => 'tasks';
  
  @override
  Task fromJson(Map<String, dynamic> json) => Task.fromJson(json);
  
  @override
  Map<String, dynamic> toJson(Task entity) => entity.toJson();
  
  @override
  String getIdFromEntity(Task entity) => entity.id;
  
  @override
  Future<List<Task>> getTasksByProject(String projectId) async {
    return await query({'project_id': projectId});
  }
  
  @override
  Future<List<Task>> getTasksByAssignee(String userId) async {
    return await query({'assigned_to': userId});
  }
  
  @override
  Future<List<Task>> getTasksByStatus(List<String> statuses) async {
    // Using a custom RPC function for array filtering
    final result = await executeQuery(
      'get_tasks_by_status',
      params: {'status_values': statuses},
    );
    
    return result;
  }
  
  @override
  Future<bool> updateTaskStatus(String taskId, String status) async {
    try {
      await _supabase
          .from(tableName)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq(primaryKeyField, taskId);
      
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update task status',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'taskId': taskId, 
          'status': status,
        },
      );
      
      throw RepositoryException(
        operation: 'updateTaskStatus',
        message: 'Failed to update status for task $taskId',
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> assignTask(String taskId, String userId) async {
    try {
      await _supabase
          .from(tableName)
          .update({
            'assigned_to': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq(primaryKeyField, taskId);
      
      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to assign task',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'taskId': taskId, 
          'userId': userId,
        },
      );
      
      throw RepositoryException(
        operation: 'assignTask',
        message: 'Failed to assign task $taskId to user $userId',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now().toIso8601String();
    
    final result = await executeQuery(
      'get_overdue_tasks',
      params: {'current_date': now},
    );
    
    return result;
  }
  
  @override
  Future<List<Task>> getTasksDueWithinDays(int days) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days)).toIso8601String();
    final currentDate = now.toIso8601String();
    
    final result = await executeQuery(
      'get_tasks_due_within_days',
      params: {
        'current_date': currentDate,
        'future_date': futureDate,
      },
    );
    
    return result;
  }
  
  @override
  Stream<List<Task>> getProjectTasksStream(String projectId) {
    // Create a stream controller
    final controller = StreamController<List<Task>>();
    
    // Initial fetch of project tasks
    getTasksByProject(projectId)
      .then((tasks) {
        if (!controller.isClosed) {
          controller.add(tasks);
        }
      })
      .catchError((e) {
        _logger.error(
          'Error fetching initial project tasks',
          category: LogCategory.realtime,
          error: e,
          additionalData: {'projectId': projectId},
        );
        
        if (!controller.isClosed) {
          controller.add([]);
        }
      });
    
    // Set up the real-time subscription for the tasks table
    final channelName = 'public:tasks:project_$projectId';
    final channel = _supabase.channel(channelName);
    
    // Set up filter for this project
    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'project_id',
      value: projectId,
    );
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: tableName,
      filter: filter,
      callback: (payload) async {
        try {
          // When any task for this project changes, refetch all project tasks
          final updatedTasks = await getTasksByProject(projectId);
          
          if (!controller.isClosed) {
            controller.add(updatedTasks);
          }
        } catch (e) {
          _logger.error(
            'Error handling project tasks update',
            category: LogCategory.realtime,
            error: e,
            additionalData: {'projectId': projectId},
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
} 