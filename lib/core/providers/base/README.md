# Base State Management Classes

This directory contains the foundational state management classes for the Workvibe application. These classes provide reusable patterns for managing state across different features.

## Overview

The base state management system consists of three main classes:

1. `BaseStateNotifier` - Simple state management
2. `BaseAsyncNotifier` - Async operation handling
3. `BaseCrudNotifier` - Collection management with CRUD operations

## Usage Patterns

### BaseStateNotifier

Use this for simple state that doesn't involve async operations:

```dart
class CounterNotifier extends BaseStateNotifier<int> {
  CounterNotifier() : super(0);
  
  void increment() => updateState(state + 1);
  void decrement() => updateStateWith((state) => state - 1);
  
  @override
  int get initialState => 0;
}
```

### BaseAsyncNotifier

Use this for state that involves loading, error handling, and async operations:

```dart
class UserProfileNotifier extends BaseAsyncNotifier<UserProfile> {
  Future<void> loadProfile(String userId) async {
    await runAsync(() async {
      final profile = await api.fetchProfile(userId);
      return profile;
    });
  }
  
  Future<void> updateProfileQuiet(UserProfile profile) async {
    await runAsyncQuiet(() async {
      await api.updateProfile(profile);
      return profile;
    });
  }
}
```

### BaseCrudNotifier

Use this for managing collections of items with CRUD operations:

```dart
class TasksNotifier extends BaseCrudNotifier<Task> {
  @override
  Future<List<Task>> loadItems() async {
    return await api.fetchTasks();
  }
  
  @override
  Future<void> saveItems(List<Task> items) async {
    await api.saveTasks(items);
  }
}
```

### WidgetRef Extensions

Use the extension methods for cleaner widget code:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch data
    final profile = ref.watchData(userProfileProvider);
    
    // Watch loading state
    final isLoading = ref.watchIsLoading(userProfileProvider);
    
    // Watch error
    final error = ref.watchError(userProfileProvider);
    
    if (isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (error != null) {
      return Text('Error: $error');
    }
    
    return Text(profile?.name ?? '');
  }
}
```

## Extension Points

When creating a new feature:

1. For simple state:
   - Extend `BaseStateNotifier`
   - Override `initialState`
   - Use `updateState` and `updateStateWith`

2. For async operations:
   - Extend `BaseAsyncNotifier`
   - Use `runAsync` for operations that should show loading
   - Use `runAsyncQuiet` for background operations

3. For collections:
   - Extend `BaseCrudNotifier`
   - Implement `loadItems` and `saveItems`
   - Use inherited CRUD operations

## Best Practices

1. Always handle errors appropriately in async operations
2. Use `runAsyncQuiet` for operations that shouldn't block the UI
3. Keep state classes focused and single-purpose
4. Leverage the WidgetRef extensions for cleaner widget code
5. Write unit tests for all state classes
6. Document complex state transformations
7. Use proper typing for all state classes

## Example Implementation

See the following files for reference implementations:

- `session_provider.dart` - Example of `BaseStateNotifier`
- `active_users_provider.dart` - Example of `BaseCrudNotifier`

## Testing

All base classes are designed to be easily testable. See `base_notifiers_test.dart` for example tests. 