import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';
import '../task_provider.dart';

/// A widget that displays a list of tasks with filtering and sorting capabilities
class TaskListConsumer extends ConsumerWidget {
  final TaskFilter filter;
  final TaskSort sort;
  final bool ascending;
  final Function(Task task)? onTaskTap;
  final Function(Task task)? onTaskLongPress;
  final Widget Function(BuildContext, Task)? taskBuilder;

  const TaskListConsumer({
    Key? key,
    this.filter = TaskFilter.all,
    this.sort = TaskSort.creationDate,
    this.ascending = true,
    this.onTaskTap,
    this.onTaskLongPress,
    this.taskBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    
    return tasksAsync.when(
      data: (tasks) {
        final filteredTasks = ref.watch(filteredTasksProvider(
          filter: filter,
          sort: sort,
          ascending: ascending,
        ));
        
        if (filteredTasks.isEmpty) {
          return const Center(
            child: Text('No tasks found'),
          );
        }
        
        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            
            if (taskBuilder != null) {
              return taskBuilder!(context, task);
            }
            
            return TaskItemConsumer(
              task: task,
              onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
              onLongPress: onTaskLongPress != null ? () => onTaskLongPress!(task) : null,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error loading tasks: $error'),
      ),
    );
  }
}

/// A widget that displays a single task with completion toggle
class TaskItemConsumer extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskItemConsumer({
    Key? key,
    required this.task,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? theme.disabledColor : null,
                      ),
                    ),
                  ),
                  _buildPriorityIndicator(task.priority),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      ref.read(taskNotifierProvider.notifier)
                          .toggleTaskCompletion(task.id);
                    },
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: task.isCompleted ? theme.disabledColor : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (task.dueDate != null)
                    Text(
                      'Due: ${dateFormat.format(task.dueDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getDueDateColor(task.dueDate!, theme),
                      ),
                    ),
                  if (task.assignees.isNotEmpty)
                    Text(
                      '${task.assignees.length} assignee${task.assignees.length > 1 ? 's' : ''}',
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
  
  Widget _buildPriorityIndicator(int priority) {
    Color color;
    
    if (priority >= 4) {
      color = Colors.red;
    } else if (priority == 3) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }
    
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
  
  Color _getDueDateColor(DateTime dueDate, ThemeData theme) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red;
    } else if (difference < 2) {
      return Colors.orange;
    } else {
      return theme.textTheme.bodySmall?.color ?? Colors.grey;
    }
  }
}

/// A widget that displays the task count by status
class TaskCountsConsumer extends ConsumerWidget {
  const TaskCountsConsumer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    
    return tasksAsync.when(
      data: (tasks) {
        final completed = tasks.where((task) => task.isCompleted).length;
        final total = tasks.length;
        final incomplete = total - completed;
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCountItem(context, 'Total', total, Colors.blue),
                    _buildCountItem(context, 'Completed', completed, Colors.green),
                    _buildCountItem(context, 'Incomplete', incomplete, Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : completed / total,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.all(16),
        color: Colors.red.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $error'),
        ),
      ),
    );
  }
  
  Widget _buildCountItem(BuildContext context, String label, int count, Color color) {
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
}

/// A widget for filtering and sorting tasks
class TaskFilterSortConsumer extends ConsumerWidget {
  final Function(TaskFilter)? onFilterChanged;
  final Function(TaskSort)? onSortChanged;
  final Function(bool)? onSortDirectionChanged;

  const TaskFilterSortConsumer({
    Key? key,
    this.onFilterChanged,
    this.onSortChanged,
    this.onSortDirectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter & Sort',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskFilter.values.map((filter) {
              return FilterChip(
                label: Text(_getFilterLabel(filter)),
                onSelected: (selected) {
                  if (selected && onFilterChanged != null) {
                    onFilterChanged!(filter);
                  }
                },
                selected: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: TaskSort.values.map((sort) {
              return FilterChip(
                label: Text(_getSortLabel(sort)),
                onSelected: (selected) {
                  if (selected && onSortChanged != null) {
                    onSortChanged!(sort);
                  }
                },
                selected: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Sort direction:'),
              const SizedBox(width: 8),
              ToggleButtons(
                isSelected: const [true, false],
                onPressed: (index) {
                  if (onSortDirectionChanged != null) {
                    onSortDirectionChanged!(index == 0);
                  }
                },
                children: const [
                  Icon(Icons.arrow_upward),
                  Icon(Icons.arrow_downward),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.incomplete:
        return 'Incomplete';
      case TaskFilter.highPriority:
        return 'High Priority';
      case TaskFilter.mediumPriority:
        return 'Medium Priority';
      case TaskFilter.lowPriority:
        return 'Low Priority';
    }
  }
  
  String _getSortLabel(TaskSort sort) {
    switch (sort) {
      case TaskSort.creationDate:
        return 'Date Created';
      case TaskSort.dueDate:
        return 'Due Date';
      case TaskSort.priority:
        return 'Priority';
      case TaskSort.title:
        return 'Title';
    }
  }
} 