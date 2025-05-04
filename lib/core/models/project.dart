import 'package:freezed_annotation/freezed_annotation.dart';
import 'task.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// Represents a project in the system
@freezed
class Project with _$Project {
  const factory Project({
    /// Unique identifier for the project
    required String id,
    
    /// Name of the project
    required String name,
    
    /// Description of the project
    required String description,
    
    /// List of tasks in the project
    @JsonKey(toJson: _tasksToJson)
    @Default([]) List<Task> tasks,
    
    /// List of team member user IDs
    @Default([]) List<String> teamMembers,
    
    /// Creation timestamp
    required DateTime createdAt,
    
    /// Last update timestamp
    required DateTime updatedAt,
    
    /// Project status (e.g., 'active', 'completed', 'archived')
    @Default('active') String status,
  }) = _Project;

  /// Create a Project instance from JSON
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}

/// Helper for serializing tasks (must be top-level for codegen)
List<Map<String, dynamic>> _tasksToJson(List<Task> tasks) =>
    tasks.map((e) => e.toJson()).toList(); 