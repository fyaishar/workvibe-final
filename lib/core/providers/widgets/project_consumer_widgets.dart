import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/project.dart';
import '../../models/task.dart';
import '../project_provider.dart';
import '../task_provider.dart';

/// A widget that displays a list of projects with filtering and sorting capabilities
class ProjectListConsumer extends ConsumerWidget {
  final ProjectFilter filter;
  final ProjectSort sort;
  final bool ascending;
  final Function(Project project)? onProjectTap;
  final Function(Project project)? onProjectLongPress;
  final Widget Function(BuildContext, Project)? projectBuilder;

  const ProjectListConsumer({
    Key? key,
    this.filter = ProjectFilter.all,
    this.sort = ProjectSort.creationDate,
    this.ascending = true,
    this.onProjectTap,
    this.onProjectLongPress,
    this.projectBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectNotifierProvider);
    
    return projectsAsync.when(
      data: (projects) {
        final filteredProjects = ref.watch(filteredProjectsProvider(
          filter: filter,
          sort: sort,
          ascending: ascending,
        ));
        
        if (filteredProjects.isEmpty) {
          return const Center(
            child: Text('No projects found'),
          );
        }
        
        return ListView.builder(
          itemCount: filteredProjects.length,
          itemBuilder: (context, index) {
            final project = filteredProjects[index];
            
            if (projectBuilder != null) {
              return projectBuilder!(context, project);
            }
            
            return ProjectItemConsumer(
              project: project,
              onTap: onProjectTap != null ? () => onProjectTap!(project) : null,
              onLongPress: onProjectLongPress != null ? () => onProjectLongPress!(project) : null,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error loading projects: $error'),
      ),
    );
  }
}

/// A widget that displays a single project with stats
class ProjectItemConsumer extends ConsumerWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTaskCount;
  final bool showMemberCount;

  const ProjectItemConsumer({
    Key? key,
    required this.project,
    this.onTap,
    this.onLongPress,
    this.showTaskCount = true,
    this.showMemberCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();
    
    // Calculate completion percentage
    final totalTasks = project.tasks.length;
    final completedTasks = project.tasks.where((task) => task.isCompleted).length;
    final completionPercentage = totalTasks > 0 
        ? (completedTasks / totalTasks * 100).toInt() 
        : 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  _buildStatusIndicator(project.status),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completion: $completionPercentage%',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                          backgroundColor: Colors.grey.shade300,
                          color: _getProgressColor(completionPercentage),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (showTaskCount)
                    _buildInfoTag(
                      context,
                      'Tasks: $totalTasks',
                      Icons.task_alt,
                    ),
                  if (showMemberCount) ...[
                    const SizedBox(width: 8),
                    _buildInfoTag(
                      context,
                      'Members: ${project.teamMembers.length}',
                      Icons.people,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${dateFormat.format(project.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Updated: ${dateFormat.format(project.updatedAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusIndicator(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        break;
      case 'archived':
        color = Colors.grey;
        label = 'Archived';
        break;
      default:
        color = Colors.orange;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
  
  Color _getProgressColor(int percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.blue;
    } else if (percentage >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  Widget _buildInfoTag(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays project tasks with assignment capabilities
class ProjectTasksConsumer extends ConsumerWidget {
  final String projectId;
  final Function(Task task)? onTaskTap;
  final Function(Task task)? onAssignTask;

  const ProjectTasksConsumer({
    Key? key,
    required this.projectId,
    this.onTaskTap,
    this.onAssignTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(projectId));
    final theme = Theme.of(context);
    
    if (tasksAsync.isEmpty) {
      return const Center(
        child: Text('No tasks in this project'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Project Tasks',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tasksAsync.length,
            itemBuilder: (context, index) {
              final task = tasksAsync[index];
              
              return ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? theme.disabledColor : null,
                  ),
                ),
                subtitle: task.description.isNotEmpty
                    ? Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) {
                    ref.read(taskNotifierProvider.notifier)
                        .toggleTaskCompletion(task.id);
                  },
                ),
                trailing: task.assignees.isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: onAssignTask != null ? () => onAssignTask!(task) : null,
                      )
                    : CircleAvatar(
                        radius: 12,
                        child: Text(
                          task.assignees.length.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A widget that displays statistics about a project
class ProjectStatsConsumer extends ConsumerWidget {
  final String projectId;

  const ProjectStatsConsumer({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final theme = Theme.of(context);
    
    if (projectAsync == null) {
      return const Center(
        child: Text('Project not found'),
      );
    }
    
    final project = projectAsync;
    final totalTasks = project.tasks.length;
    final completedTasks = project.tasks.where((task) => task.isCompleted).length;
    final incompleteTasks = totalTasks - completedTasks;
    final completion = totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Overview',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Total Tasks', totalTasks, Colors.blue),
                _buildStatItem(context, 'Completed', completedTasks, Colors.green),
                _buildStatItem(context, 'Pending', incompleteTasks, Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Completion: $completion%',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: totalTasks > 0 ? completedTasks / totalTasks : 0,
              backgroundColor: Colors.grey.shade300,
              color: _getProgressColor(completion),
            ),
            const SizedBox(height: 16),
            Text(
              'Team Members: ${project.teamMembers.length}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Color _getProgressColor(int percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.blue;
    } else if (percentage >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 