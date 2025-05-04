import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Represents a task in the system
@freezed
class Task with _$Task {
  const factory Task({
    /// Unique identifier for the task
    required String id,
    
    /// Title of the task
    required String title,
    
    /// Detailed description of the task
    required String description,
    
    /// Whether the task is completed
    @Default(false) bool isCompleted,
    
    /// Due date for the task
    DateTime? dueDate,
    
    /// Priority level (1-5, where 5 is highest)
    @Default(3) int priority,
    
    /// List of assignee user IDs
    @Default([]) List<String> assignees,
    
    /// List of labels/tags
    @Default([]) List<String> labels,
    
    /// Creation timestamp
    required DateTime createdAt,
    
    /// Last update timestamp
    required DateTime updatedAt,
  }) = _Task;

  /// Create a Task instance from JSON
  factory Task.fromJson(Map<String, dynamic> json) =>
      _$TaskFromJson(json);
} 