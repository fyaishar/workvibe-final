import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:async';

import '../models/task.dart';
import '../providers/base/base_crud_notifier.dart';
import '../../services/supabase_service.dart';
import '../../services/supabase_realtime_service.dart';

part 'task_provider.g.dart';

/// Task filter options
enum TaskFilter {
  all,
  completed,
  incomplete,
  highPriority,
  mediumPriority,
  lowPriority,
}

/// Task sort options
enum TaskSort {
  creationDate,
  dueDate,
  priority,
  title,
}

/// Notifier for managing tasks with filtered views and sorting
@riverpod
class TaskNotifier extends _$TaskNotifier {
  final SupabaseRealtimeService _realtimeService = SupabaseRealtimeService();
  StreamSubscription? _taskSubscription;
  
  @override
  Future<List<Task>> build() async {
    ref.onDispose(() {
      _taskSubscription?.cancel();
    });
    
    // Listen for real-time task updates
    _taskSubscription = _realtimeService.onTaskEvent.listen(_handleTaskEvent);
    
    return _fetchTasks();
  }
  
  /// Handle real-time task events
  void _handleTaskEvent(Map<String, dynamic> event) {
    final eventType = event['type'] as String;
    final data = event['data'] as Map<String, dynamic>;
    
    switch (eventType) {
      case 'create-task':
        _handleTaskCreated(Task.fromJson(data));
        break;
      case 'update-task-details':
        _handleTaskUpdated(Task.fromJson(data));
        break;
      default:
        // Refresh all tasks if we don't recognize the event
        ref.invalidateSelf();
    }
  }
  
  /// Handle task creation event
  void _handleTaskCreated(Task task) {
    state = AsyncData([...state.valueOrNull ?? [], task]);
  }
  
  /// Handle task update event
  void _handleTaskUpdated(Task updatedTask) {
    if (state.hasValue) {
      final updatedTasks = state.value!.map((task) {
        return task.id == updatedTask.id ? updatedTask : task;
      }).toList();
      
      state = AsyncData(updatedTasks);
    }
  }
  
  /// Fetch all tasks from Supabase
  Future<List<Task>> _fetchTasks() async {
    try {
      final response = await SupabaseService.client
          .from('tasks')
          .select()
          .order('created_at');
      
      final tasks = (response as List)
          .map((json) => Task.fromJson(json))
          .toList();
      
      return tasks;
    } catch (e, stackTrace) {
      debugPrint('Error fetching tasks: $e');
      throw AsyncError(e, stackTrace);
    }
  }
  
  /// Create a new task
  Future<void> createTask(Task task) async {
    state = const AsyncLoading();
    
    try {
      await SupabaseService.client
          .from('tasks')
          .insert(task.toJson());
      
      state = AsyncData([...state.valueOrNull ?? [], task]);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error creating task: $e');
    }
  }
  
  /// Update an existing task
  Future<void> updateTask(Task task) async {
    if (!state.hasValue) return;
    
    // Optimistically update the UI
    final previousState = state.valueOrNull;
    final updatedTasks = state.value!.map((t) {
      return t.id == task.id ? task : t;
    }).toList();
    
    state = AsyncData(updatedTasks);
    
    try {
      await SupabaseService.client
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id);
    } catch (e, stackTrace) {
      // Restore previous state on error
      state = previousState != null
          ? AsyncData(previousState)
          : AsyncError(e, stackTrace);
      debugPrint('Error updating task: $e');
    }
  }
  
  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    if (!state.hasValue) return;
    
    // Optimistically update the UI
    final previousState = state.valueOrNull;
    final updatedTasks = state.value!
        .where((task) => task.id != taskId)
        .toList();
    
    state = AsyncData(updatedTasks);
    
    try {
      await SupabaseService.client
          .from('tasks')
          .delete()
          .eq('id', taskId);
    } catch (e, stackTrace) {
      // Restore previous state on error
      state = previousState != null
          ? AsyncData(previousState)
          : AsyncError(e, stackTrace);
      debugPrint('Error deleting task: $e');
    }
  }
  
  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    if (!state.hasValue) return;
    
    final task = state.value!.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return;
    
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    
    await updateTask(updatedTask);
  }
  
  /// Refresh tasks from the server
  Future<void> refreshTasks() async {
    state = const AsyncLoading();
    
    try {
      final tasks = await _fetchTasks();
      state = AsyncData(tasks);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error refreshing tasks: $e');
    }
  }
}

/// Provider for accessing filtered tasks
@riverpod
List<Task> filteredTasks(FilteredTasksRef ref, {
  required TaskFilter filter,
  TaskSort sort = TaskSort.creationDate,
  bool ascending = true,
}) {
  final tasksAsync = ref.watch(taskNotifierProvider);
  
  if (!tasksAsync.hasValue) return [];
  
  final tasks = tasksAsync.value!;
  List<Task> filtered;
  
  // Apply filter
  switch (filter) {
    case TaskFilter.all:
      filtered = List.from(tasks);
      break;
    case TaskFilter.completed:
      filtered = tasks.where((task) => task.isCompleted).toList();
      break;
    case TaskFilter.incomplete:
      filtered = tasks.where((task) => !task.isCompleted).toList();
      break;
    case TaskFilter.highPriority:
      filtered = tasks.where((task) => task.priority >= 4).toList();
      break;
    case TaskFilter.mediumPriority:
      filtered = tasks.where((task) => task.priority == 3).toList();
      break;
    case TaskFilter.lowPriority:
      filtered = tasks.where((task) => task.priority <= 2).toList();
      break;
  }
  
  // Apply sort
  switch (sort) {
    case TaskSort.title:
      filtered.sort((a, b) => ascending
          ? a.title.compareTo(b.title)
          : b.title.compareTo(a.title));
      break;
    case TaskSort.priority:
      filtered.sort((a, b) => ascending
          ? a.priority.compareTo(b.priority)
          : b.priority.compareTo(a.priority));
      break;
    case TaskSort.dueDate:
      filtered.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return ascending ? 1 : -1;
        if (b.dueDate == null) return ascending ? -1 : 1;
        return ascending
            ? a.dueDate!.compareTo(b.dueDate!)
            : b.dueDate!.compareTo(a.dueDate!);
      });
      break;
    case TaskSort.creationDate:
    default:
      filtered.sort((a, b) => ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
  }
  
  return filtered;
}

/// Provider for accessing a task by ID
@riverpod
Task? taskById(TaskByIdRef ref, String id) {
  final tasksAsync = ref.watch(taskNotifierProvider);
  
  if (!tasksAsync.hasValue) return null;
  
  return tasksAsync.value!.firstWhereOrNull((task) => task.id == id);
}

/// Provider for tasks assigned to the current user
@riverpod
List<Task> userTasks(UserTasksRef ref, String userId) {
  final tasksAsync = ref.watch(taskNotifierProvider);
  
  if (!tasksAsync.hasValue) return [];
  
  return tasksAsync.value!
      .where((task) => task.assignees.contains(userId))
      .toList();
} 