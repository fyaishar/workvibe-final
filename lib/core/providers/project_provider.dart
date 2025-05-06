import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:async';

import '../models/project.dart';
import '../models/task.dart';
import '../providers/base/base_crud_notifier.dart';
import '../providers/task_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/supabase_realtime_service.dart';

// This part file will be generated after running the build_runner
part 'project_provider.g.dart';

/// Project filter options
enum ProjectFilter {
  all,
  active,
  completed,
  archived,
}

/// Project sort options
enum ProjectSort {
  creationDate,
  name,
  taskCount,
  updatedAt,
}

/// Notifier for managing projects with filtered views and sorting
@riverpod
class ProjectNotifier extends _$ProjectNotifier {
  final SupabaseRealtimeService _realtimeService = SupabaseRealtimeService();
  StreamSubscription? _projectSubscription;
  
  @override
  Future<List<Project>> build() async {
    ref.onDispose(() {
      _projectSubscription?.cancel();
    });
    
    // Listen for real-time project updates
    _projectSubscription = _realtimeService.onProjectEvent.listen(_handleProjectEvent);
    
    return _fetchProjects();
  }
  
  /// Handle real-time project events
  void _handleProjectEvent(Map<String, dynamic> event) {
    final eventType = event['type'] as String;
    final data = event['data'] as Map<String, dynamic>;
    
    switch (eventType) {
      case 'create-project':
        _handleProjectCreated(Project.fromJson(data));
        break;
      case 'update-project':
        _handleProjectUpdated(Project.fromJson(data));
        break;
      default:
        // Refresh all projects if we don't recognize the event
        ref.invalidateSelf();
    }
  }
  
  /// Handle project creation event
  void _handleProjectCreated(Project project) {
    state = AsyncData([...state.valueOrNull ?? [], project]);
  }
  
  /// Handle project update event
  void _handleProjectUpdated(Project updatedProject) {
    if (state.hasValue) {
      final updatedProjects = state.value!.map((project) {
        return project.id == updatedProject.id ? updatedProject : project;
      }).toList();
      
      state = AsyncData(updatedProjects);
    }
  }
  
  /// Fetch all projects from Supabase
  Future<List<Project>> _fetchProjects() async {
    try {
      final response = await SupabaseService.client
          .from('projects')
          .select()
          .order('created_at');
      
      final projects = (response as List)
          .map((json) => Project.fromJson(json))
          .toList();
      
      return projects;
    } catch (e, stackTrace) {
      debugPrint('Error fetching projects: $e');
      throw AsyncError(e, stackTrace);
    }
  }
  
  /// Create a new project
  Future<void> createProject(Project project) async {
    state = const AsyncLoading();
    
    try {
      await SupabaseService.client
          .from('projects')
          .insert(project.toJson());
      
      state = AsyncData([...state.valueOrNull ?? [], project]);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error creating project: $e');
    }
  }
  
  /// Update an existing project
  Future<void> updateProject(Project project) async {
    if (!state.hasValue) return;
    
    // Optimistically update the UI
    final previousState = state.valueOrNull;
    final updatedProjects = state.value!.map((p) {
      return p.id == project.id ? project : p;
    }).toList();
    
    state = AsyncData(updatedProjects);
    
    try {
      await SupabaseService.client
          .from('projects')
          .update(project.toJson())
          .eq('id', project.id);
    } catch (e, stackTrace) {
      // Restore previous state on error
      state = previousState != null
          ? AsyncData(previousState)
          : AsyncError(e, stackTrace);
      debugPrint('Error updating project: $e');
    }
  }
  
  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    if (!state.hasValue) return;
    
    // Optimistically update the UI
    final previousState = state.valueOrNull;
    final updatedProjects = state.value!
        .where((project) => project.id != projectId)
        .toList();
    
    state = AsyncData(updatedProjects);
    
    try {
      await SupabaseService.client
          .from('projects')
          .delete()
          .eq('id', projectId);
    } catch (e, stackTrace) {
      // Restore previous state on error
      state = previousState != null
          ? AsyncData(previousState)
          : AsyncError(e, stackTrace);
      debugPrint('Error deleting project: $e');
    }
  }
  
  /// Add a task to a project
  Future<void> addTaskToProject(String projectId, Task task) async {
    if (!state.hasValue) return;
    
    final project = state.value!.firstWhereOrNull((p) => p.id == projectId);
    if (project == null) return;
    
    final updatedProject = project.copyWith(
      tasks: [...project.tasks, task],
      updatedAt: DateTime.now(),
    );
    
    await updateProject(updatedProject);
  }
  
  /// Remove a task from a project
  Future<void> removeTaskFromProject(String projectId, String taskId) async {
    if (!state.hasValue) return;
    
    final project = state.value!.firstWhereOrNull((p) => p.id == projectId);
    if (project == null) return;
    
    final updatedProject = project.copyWith(
      tasks: project.tasks.where((task) => task.id != taskId).toList(),
      updatedAt: DateTime.now(),
    );
    
    await updateProject(updatedProject);
  }
  
  /// Add a team member to a project
  Future<void> addTeamMember(String projectId, String userId) async {
    if (!state.hasValue) return;
    
    final project = state.value!.firstWhereOrNull((p) => p.id == projectId);
    if (project == null) return;
    
    // Only add if not already a member
    if (project.teamMembers.contains(userId)) return;
    
    final updatedProject = project.copyWith(
      teamMembers: [...project.teamMembers, userId],
      updatedAt: DateTime.now(),
    );
    
    await updateProject(updatedProject);
  }
  
  /// Remove a team member from a project
  Future<void> removeTeamMember(String projectId, String userId) async {
    if (!state.hasValue) return;
    
    final project = state.value!.firstWhereOrNull((p) => p.id == projectId);
    if (project == null) return;
    
    final updatedProject = project.copyWith(
      teamMembers: project.teamMembers.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
    
    await updateProject(updatedProject);
  }
  
  /// Archive a project
  Future<void> archiveProject(String projectId) async {
    if (!state.hasValue) return;
    
    final project = state.value!.firstWhereOrNull((p) => p.id == projectId);
    if (project == null) return;
    
    final updatedProject = project.copyWith(
      status: 'archived',
      updatedAt: DateTime.now(),
    );
    
    await updateProject(updatedProject);
  }
  
  /// Refresh projects from the server
  Future<void> refreshProjects() async {
    state = const AsyncLoading();
    
    try {
      final projects = await _fetchProjects();
      state = AsyncData(projects);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error refreshing projects: $e');
    }
  }
}

/// Provider for accessing filtered projects
@riverpod
List<Project> filteredProjects(FilteredProjectsRef ref, {
  required ProjectFilter filter,
  ProjectSort sort = ProjectSort.creationDate,
  bool ascending = true,
}) {
  final projectsAsync = ref.watch(projectNotifierProvider);
  
  if (!projectsAsync.hasValue) return [];
  
  final projects = projectsAsync.value!;
  List<Project> filtered;
  
  // Apply filter
  switch (filter) {
    case ProjectFilter.all:
      filtered = List.from(projects);
      break;
    case ProjectFilter.active:
      filtered = projects.where((project) => project.status == 'active').toList();
      break;
    case ProjectFilter.completed:
      filtered = projects.where((project) => project.status == 'completed').toList();
      break;
    case ProjectFilter.archived:
      filtered = projects.where((project) => project.status == 'archived').toList();
      break;
  }
  
  // Apply sort
  switch (sort) {
    case ProjectSort.name:
      filtered.sort((a, b) => ascending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
      break;
    case ProjectSort.taskCount:
      filtered.sort((a, b) => ascending
          ? a.tasks.length.compareTo(b.tasks.length)
          : b.tasks.length.compareTo(a.tasks.length));
      break;
    case ProjectSort.updatedAt:
      filtered.sort((a, b) => ascending
          ? a.updatedAt.compareTo(b.updatedAt)
          : b.updatedAt.compareTo(a.updatedAt));
      break;
    case ProjectSort.creationDate:
    default:
      filtered.sort((a, b) => ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
  }
  
  return filtered;
}

/// Provider for accessing a project by ID
@riverpod
Project? projectById(ProjectByIdRef ref, String id) {
  final projectsAsync = ref.watch(projectNotifierProvider);
  
  if (!projectsAsync.hasValue) return null;
  
  return projectsAsync.value!.firstWhereOrNull((project) => project.id == id);
}

/// Provider for projects that a user is a member of
@riverpod
List<Project> userProjects(UserProjectsRef ref, String userId) {
  final projectsAsync = ref.watch(projectNotifierProvider);
  
  if (!projectsAsync.hasValue) return [];
  
  return projectsAsync.value!
      .where((project) => project.teamMembers.contains(userId))
      .toList();
}

/// Provider for project tasks (returns all tasks for a specific project)
@riverpod
List<Task> projectTasks(ProjectTasksRef ref, String projectId) {
  final projectAsync = ref.watch(projectByIdProvider(projectId));
  
  if (projectAsync == null) return [];
  
  return projectAsync.tasks;
} 