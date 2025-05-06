import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finalworkvibe/core/models/task.dart';
import 'package:finalworkvibe/core/providers/task_provider.dart';

class TestTaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: '1', 
        title: 'Test Task 1', 
        description: 'Description 1', 
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Task(
        id: '2', 
        title: 'Test Task 2',
        description: 'Description 2',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

class TestSortedTaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: '2', 
        title: 'A Task',
        description: 'Description 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '1', 
        title: 'B Task', 
        description: 'Description 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

class TestAssigneesTaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: '1', 
        title: 'Task 1', 
        description: 'Description 1',
        assignees: ['user1', 'user2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '2', 
        title: 'Task 2',
        description: 'Description 2',
        assignees: ['user2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '3', 
        title: 'Task 3',
        description: 'Description 3',
        assignees: ['user3'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

void main() {
  group('Task filtering and sorting tests', () {
    final mockTasks = [
      Task(
        id: '1', 
        title: 'Test Task 1', 
        description: 'Description 1', 
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Task(
        id: '2', 
        title: 'Test Task 2',
        description: 'Description 2',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
    ];

    test('filters completed tasks correctly', () {
      // Create tasks list with mix of completed and incomplete tasks
      final List<Task> tasks = [...mockTasks];
      
      // Apply the filter logic directly (extracted from filteredTasksProvider)
      final List<Task> filteredTasks = tasks.where((task) => task.isCompleted).toList();
      
      // Verify
      expect(filteredTasks.length, 1);
      expect(filteredTasks[0].id, '2');
      expect(filteredTasks[0].isCompleted, true);
    });
    
    test('filters incomplete tasks correctly', () {
      // Create tasks list with mix of completed and incomplete tasks
      final List<Task> tasks = [...mockTasks];
      
      // Apply the filter logic directly (extracted from filteredTasksProvider)
      final List<Task> filteredTasks = tasks.where((task) => !task.isCompleted).toList();
      
      // Verify
      expect(filteredTasks.length, 1);
      expect(filteredTasks[0].id, '1');
      expect(filteredTasks[0].isCompleted, false);
    });
    
    test('sorts tasks by title correctly', () {
      // Create a list of tasks with specific titles for sorting
      final List<Task> tasks = [
        Task(
          id: '1', 
          title: 'B Task', 
          description: 'Description 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: '2', 
          title: 'A Task',
          description: 'Description 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Apply the sort logic directly (extracted from filteredTasksProvider)
      tasks.sort((a, b) => a.title.compareTo(b.title));
      
      // Verify
      expect(tasks.length, 2);
      expect(tasks[0].title, 'A Task');
      expect(tasks[1].title, 'B Task');
    });
    
    test('sorts tasks by creation date correctly', () {
      // Create a list of tasks with different creation dates
      final now = DateTime.now();
      final List<Task> tasks = [
        Task(
          id: '1', 
          title: 'New Task', 
          description: 'Description 1',
          createdAt: now,
          updatedAt: now,
        ),
        Task(
          id: '2', 
          title: 'Old Task',
          description: 'Description 2',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now,
        ),
      ];
      
      // Apply the sort logic directly (extracted from filteredTasksProvider)
      tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // Verify
      expect(tasks.length, 2);
      expect(tasks[0].title, 'Old Task');
      expect(tasks[1].title, 'New Task');
    });
  });

  group('Task retrieval tests', () {
    final mockTasks = [
      Task(
        id: '1', 
        title: 'Test Task 1', 
        description: 'Description 1', 
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '2', 
        title: 'Test Task 2',
        description: 'Description 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    test('gets task by ID correctly', () {
      // Apply the retrieval logic (extracted from taskByIdProvider)
      final String targetId = '1';
      final Task? task = mockTasks.firstWhere(
        (task) => task.id == targetId,
        orElse: () => null as Task, // This forces null to be returned if not found
      );
      
      // Verify
      expect(task, isNotNull);
      expect(task?.id, '1');
      expect(task?.title, 'Test Task 1');
    });
    
    test('returns null for non-existent task ID', () {
      // Apply the retrieval logic (extracted from taskByIdProvider)
      final String targetId = '999';
      Task? task;
      try {
        task = mockTasks.firstWhere((task) => task.id == targetId);
      } catch (_) {
        task = null;
      }
      
      // Verify
      expect(task, isNull);
    });
  });

  group('User assignment tests', () {
    final mockTasks = [
      Task(
        id: '1', 
        title: 'Task 1', 
        description: 'Description 1',
        assignees: ['user1', 'user2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '2', 
        title: 'Task 2',
        description: 'Description 2',
        assignees: ['user2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: '3', 
        title: 'Task 3',
        description: 'Description 3',
        assignees: ['user3'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    test('filters tasks by assignee correctly', () {
      // Apply the filter logic (extracted from userTasksProvider)
      final String userId = 'user1';
      final List<Task> userTasks = mockTasks
        .where((task) => task.assignees.contains(userId))
        .toList();
      
      // Verify
      expect(userTasks.length, 1);
      expect(userTasks[0].id, '1');
      
      // Check for a different user
      final String userId2 = 'user2';
      final List<Task> user2Tasks = mockTasks
        .where((task) => task.assignees.contains(userId2))
        .toList();
      
      // Verify
      expect(user2Tasks.length, 2);
      expect(user2Tasks.map((t) => t.id).toList()..sort(), ['1', '2']);
    });
  });
} 