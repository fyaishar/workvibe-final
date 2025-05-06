# Riverpod Providers Documentation

This directory contains the state management implementation using Riverpod providers. The code is structured to be modular, maintainable, and performant.

## Overview

The implementation follows a few key principles:

1. **Code generation** - Using `@riverpod` annotations for automatic provider generation
2. **State immutability** - Using Freezed models for immutable state
3. **Optimistic updates** - Updating UI immediately then syncing with backend
4. **Real-time capabilities** - Integration with Supabase Realtime for live updates
5. **Proper error handling** - Using AsyncValue for loading and error states

## Directory Structure

```
lib/core/providers/
│
├── base/                     # Base abstractions for providers
│   ├── base_state_notifier.dart     # Simple state management
│   ├── base_async_notifier.dart     # Async state with loading/error
│   ├── base_crud_notifier.dart      # CRUD operations
│   └── ref_extensions.dart          # Utility extensions for Ref
│
├── widgets/                  # Consumer widgets that use providers
│   ├── task_consumer_widgets.dart   # UI components for tasks
│   └── project_consumer_widgets.dart # UI components for projects
│
├── session_provider.dart     # Session management
├── active_users_provider.dart # User presence management
├── task_provider.dart        # Task state management
├── project_provider.dart     # Project state management
└── README.md                 # This documentation
```

## Provider Types

### 1. State Notifiers

These are the main state containers that handle loading, data, and error states:

```dart
@riverpod
class TaskNotifier extends _$TaskNotifier {
  @override
  Future<List<Task>> build() async {
    // Initial state setup
  }
  
  // Methods to modify state
}
```

### 2. Derived Providers

These providers derive their state from other providers:

```dart
@riverpod
List<Task> filteredTasks(FilteredTasksRef ref, {
  required TaskFilter filter,
  TaskSort sort = TaskSort.creationDate,
  bool ascending = true,
}) {
  final tasksAsync = ref.watch(taskNotifierProvider);
  // Filter and sort logic
}
```

### 3. Family Providers

These providers take parameters to provide specific data:

```dart
@riverpod
Task? taskById(TaskByIdRef ref, String id) {
  final tasksAsync = ref.watch(taskNotifierProvider);
  // Return specific task by ID
}
```

## Usage Guide

### Session Management

The `sessionNotifierProvider` manages the current user's session state:

```dart
// Read the current session
final session = ref.watch(sessionNotifierProvider);

// Check if user is logged in
final isLoggedIn = ref.watch(isLoggedInProvider);

// Update the session
ref.read(sessionNotifierProvider.notifier).updateSession(newSession);

// Clear the session (logout)
ref.read(sessionNotifierProvider.notifier).clearSession();
```

### Task Management

The `taskNotifierProvider` manages all tasks in the application:

```dart
// Read all tasks (returns AsyncValue<List<Task>>)
final tasksAsync = ref.watch(taskNotifierProvider);

// Handle the different states
tasksAsync.when(
  data: (tasks) => /* Display tasks */,
  loading: () => /* Show loading indicator */,
  error: (error, stack) => /* Show error message */,
);

// Create a new task
ref.read(taskNotifierProvider.notifier).createTask(newTask);

// Update a task
ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);

// Delete a task
ref.read(taskNotifierProvider.notifier).deleteTask(taskId);

// Toggle task completion
ref.read(taskNotifierProvider.notifier).toggleTaskCompletion(taskId);

// Get filtered tasks
final filteredTasks = ref.watch(filteredTasksProvider(
  filter: TaskFilter.incomplete,
  sort: TaskSort.dueDate,
  ascending: true,
));

// Get tasks by ID
final task = ref.watch(taskByIdProvider(taskId));

// Get tasks assigned to a user
final userTasks = ref.watch(userTasksProvider(userId));
```

### Project Management

The `projectNotifierProvider` manages all projects in the application:

```dart
// Read all projects (returns AsyncValue<List<Project>>)
final projectsAsync = ref.watch(projectNotifierProvider);

// Create a new project
ref.read(projectNotifierProvider.notifier).createProject(newProject);

// Update a project
ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);

// Delete a project
ref.read(projectNotifierProvider.notifier).deleteProject(projectId);

// Add or remove tasks
ref.read(projectNotifierProvider.notifier).addTaskToProject(projectId, task);
ref.read(projectNotifierProvider.notifier).removeTaskFromProject(projectId, taskId);

// Manage team members
ref.read(projectNotifierProvider.notifier).addTeamMember(projectId, userId);
ref.read(projectNotifierProvider.notifier).removeTeamMember(projectId, userId);

// Change project status
ref.read(projectNotifierProvider.notifier).archiveProject(projectId);

// Get filtered projects
final filteredProjects = ref.watch(filteredProjectsProvider(
  filter: ProjectFilter.active,
  sort: ProjectSort.updatedAt,
  ascending: false,
));

// Get project by ID
final project = ref.watch(projectByIdProvider(projectId));

// Get user's projects
final userProjects = ref.watch(userProjectsProvider(userId));

// Get tasks for a project
final projectTasks = ref.watch(projectTasksProvider(projectId));
```

### Active Users Management

The `activeUsersNotifierProvider` manages the list of active users:

```dart
// Read all active users
final allUsers = ref.watch(activeUsersProvider);

// Get only online users
final onlineUsers = ref.watch(onlineUsersProvider);

// Update a user's status
ref.read(activeUsersNotifierProvider.notifier).updateUserStatus(
  userId, 
  UserStatus.active,
  statusMessage: "Working on Task #42",
);
```

## Consumer Widgets

For common UI patterns, we've created consumer widgets that automatically connect to the providers:

### Task Widgets

- `TaskListConsumer` - Displays a filterable, sortable list of tasks
- `TaskItemConsumer` - Displays a single task with completion toggle
- `TaskCountsConsumer` - Shows statistics about tasks (total, completed, etc.)
- `TaskFilterSortConsumer` - UI for filtering and sorting tasks

### Project Widgets

- `ProjectListConsumer` - Displays a filterable, sortable list of projects
- `ProjectItemConsumer` - Displays a single project with completion status
- `ProjectTasksConsumer` - Shows tasks within a project
- `ProjectStatsConsumer` - Shows statistics about a project

## Error Handling

All async providers use `AsyncValue` to represent the three possible states:

1. `AsyncData` - Operation completed successfully with data
2. `AsyncLoading` - Operation in progress
3. `AsyncError` - Operation failed with error

Consumer code should handle all three states:

```dart
ref.watch(taskNotifierProvider).when(
  data: (tasks) {
    // Handle data
  },
  loading: () {
    // Show loading indicator
  },
  error: (error, stackTrace) {
    // Show error message
  },
);
```

## Best Practices

1. **Keep providers focused** - Each provider should have a single responsibility
2. **Use derived state** - Create derived providers for computed values
3. **Optimize rebuilds** - Use `select()` to watch specific parts of state
4. **Handle errors** - Always handle error states in the UI
5. **Clean up resources** - Use `ref.onDispose` to clean up subscriptions
6. **Favor immutability** - Never mutate state directly

## Running Code Generation

After modifying providers with `@riverpod` annotations, you need to run code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing Providers

When testing providers, use `ProviderContainer` to create isolated instances:

```dart
final container = ProviderContainer();
final tasksAsync = container.read(taskNotifierProvider);
```

Use `ProviderScope` in widget tests:

```dart
testWidgets('Task list displays correctly', (tester) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      taskNotifierProvider.overrideWithValue(/* mock value */),
    ],
    child: const MyApp(),
  ));
  // Test assertions
});
``` 