import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../mocks/mock_models.dart';
import '../mocks/mock_supabase.dart';
import 'mock_task_repository.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late TestTaskRepository taskRepository;

  const testTaskId = 'test-task-1';
  
  setUp(() {
    // Setup mock client
    mockSupabaseClient = MockSupabaseClient();
    
    // Initialize repository with mock client
    taskRepository = TestTaskRepository(mockSupabaseClient);
    
    // Seed mock database with test tasks
    mockSupabaseClient.simulateInsert('tasks', {
      'id': testTaskId,
      'title': 'Test Task',
      'description': 'This is a test task',
      'status': 'pending',
      'due_date': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      'assigned_to': 'user-1',
      'project_id': 'project-1',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    mockSupabaseClient.simulateInsert('tasks', {
      'id': 'test-task-2',
      'title': 'Completed Task',
      'description': 'This task is already done',
      'status': 'completed',
      'assigned_to': 'user-2',
      'project_id': 'project-1',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  });

  group('TaskRepository', () {
    test('getById returns correct task', () async {
      final task = await taskRepository.getById(testTaskId);
      
      expect(task, isNotNull);
      expect(task?.id, equals(testTaskId));
      expect(task?.title, equals('Test Task'));
      expect(task?.status, equals('pending'));
    });
    
    test('getAll returns all tasks', () async {
      final tasks = await taskRepository.getAll();
      
      expect(tasks.length, equals(2));
      expect(tasks.any((t) => t.id == testTaskId), isTrue);
      expect(tasks.any((t) => t.status == 'completed'), isTrue);
    });
    
    test('getTasksByProject returns tasks for a specific project', () async {
      final tasks = await taskRepository.getTasksByProject('project-1');
      
      expect(tasks.length, equals(2));
      expect(tasks.any((t) => t.id == testTaskId), isTrue);
      expect(tasks.any((t) => t.id == 'test-task-2'), isTrue);
    });
    
    test('getTasksByAssignee returns tasks for a specific user', () async {
      final tasks = await taskRepository.getTasksByAssignee('user-1');
      
      expect(tasks.length, equals(1));
      expect(tasks.first.id, equals(testTaskId));
      expect(tasks.first.assignedTo, equals('user-1'));
    });
    
    test('getTasksByStatus returns tasks with matching status', () async {
      final pendingTasks = await taskRepository.getTasksByStatus(['pending']);
      
      expect(pendingTasks.length, equals(1));
      expect(pendingTasks.first.id, equals(testTaskId));
      expect(pendingTasks.first.status, equals('pending'));
      
      final completedTasks = await taskRepository.getTasksByStatus(['completed']);
      
      expect(completedTasks.length, equals(1));
      expect(completedTasks.first.id, equals('test-task-2'));
      expect(completedTasks.first.status, equals('completed'));
    });
    
    test('updateTaskStatus changes task status', () async {
      await taskRepository.updateTaskStatus(testTaskId, 'in-progress');
      
      final task = await taskRepository.getById(testTaskId);
      expect(task?.status, equals('in-progress'));
    });
    
    test('assignTask changes task assignee', () async {
      await taskRepository.assignTask(testTaskId, 'user-3');
      
      final task = await taskRepository.getById(testTaskId);
      expect(task?.assignedTo, equals('user-3'));
    });
    
    test('subscribe emits tasks and updates on changes', () async {
      final stream = taskRepository.subscribe();
      
      // Initial emission should contain all tasks
      final initialTasks = await stream.first;
      expect(initialTasks.length, equals(2));
      
      // Add a new task
      mockSupabaseClient.simulateInsert('tasks', {
        'id': 'test-task-3',
        'title': 'New Task',
        'description': 'This is a new task',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Next emission should include the new task
      final updatedTasks = await stream.first;
      expect(updatedTasks.length, equals(3));
      expect(updatedTasks.any((t) => t.id == 'test-task-3'), isTrue);
    });
    
    test('subscribeToId emits single task updates', () async {
      final stream = taskRepository.subscribeToId(testTaskId);
      
      // Initial emission should be the test task
      final initialTask = await stream.first;
      expect(initialTask?.id, equals(testTaskId));
      
      // Update the task
      mockSupabaseClient.simulateUpdate('tasks', testTaskId, {
        'id': testTaskId,
        'title': 'Updated Task',
        'description': 'This task was updated',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Next emission should have the updated task
      final updatedTask = await stream.first;
      expect(updatedTask?.title, equals('Updated Task'));
      
      // Delete the task
      mockSupabaseClient.simulateDelete('tasks', testTaskId);
      
      // Next emission should be null
      final finalTask = await stream.first;
      expect(finalTask, isNull);
    });
  });
} 