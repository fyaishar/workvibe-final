import '../../models/task.dart';
import 'base_repository.dart';

/// Interface for task-specific repository operations
abstract class ITaskRepository extends IRepository<Task> {
  /// Get tasks associated with a specific project
  Future<List<Task>> getTasksByProject(String projectId);
  
  /// Get tasks assigned to a specific user
  Future<List<Task>> getTasksByAssignee(String userId);
  
  /// Get tasks that have one of the provided statuses
  Future<List<Task>> getTasksByStatus(List<String> statuses);
  
  /// Update a task's status
  Future<bool> updateTaskStatus(String taskId, String status);
  
  /// Assign a task to a user
  Future<bool> assignTask(String taskId, String userId);
  
  /// Get overdue tasks
  Future<List<Task>> getOverdueTasks();
  
  /// Get tasks due within a specified number of days
  Future<List<Task>> getTasksDueWithinDays(int days);
  
  /// Get a stream of tasks for a specific project
  Stream<List<Task>> getProjectTasksStream(String projectId);
} 