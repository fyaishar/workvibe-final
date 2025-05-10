import 'dart:async';
import 'package:finalworkvibe/core/models/user_status.dart';
import '../mocks/mock_models.dart';

/// Base repository interface for testing that uses mock models
abstract class MockRepository<T> {
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<List<T>> query(Map<String, dynamic> queryParams);
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<bool> delete(String id);
  Stream<List<T>> subscribe();
  Stream<T?> subscribeToId(String id);
  Future<List<T>> executeQuery(String query, {Map<String, dynamic>? params});
}

/// Interface for mock user repository
abstract class MockUserRepository extends MockRepository<MockUser> {
  Future<MockUser?> getUserByEmail(String email);
  Future<List<MockUser>> getUsersByStatus(List<String> statuses);
  Future<List<MockUser>> searchUsers(String searchTerm);
  Future<bool> updateUserStatus(String userId, String status, {String? statusMessage});
  Stream<List<MockUser>> getActiveUsersStream();
}

/// Interface for mock task repository
abstract class MockTaskRepository extends MockRepository<MockTask> {
  Future<List<MockTask>> getTasksByProject(String projectId);
  Future<List<MockTask>> getTasksByAssignee(String userId);
  Future<List<MockTask>> getTasksByStatus(List<String> statuses);
  Future<bool> updateTaskStatus(String taskId, String status);
  Future<bool> assignTask(String taskId, String userId);
  Future<List<MockTask>> getOverdueTasks();
  Future<List<MockTask>> getTasksDueWithinDays(int days);
  Stream<List<MockTask>> getProjectTasksStream(String projectId);
} 