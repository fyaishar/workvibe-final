import 'package:flutter_test/flutter_test.dart';
import 'package:finalworkvibe/core/models/session_info.dart';
import 'package:finalworkvibe/core/models/task.dart';
import 'package:finalworkvibe/core/models/project.dart';
import 'package:finalworkvibe/core/models/user_status.dart';

void main() {
  group('Models Tests', () {
    test('UserStatus serialization', () {
      expect(UserStatus.active.toJson(), 'active');
      expect(UserStatus.fromJson('active'), UserStatus.active);
      expect(UserStatus.fromJson('invalid'), UserStatus.offline);
    });

    test('SessionInfo serialization', () {
      final now = DateTime.now();
      final session = SessionInfo(
        id: '123',
        username: 'testUser',
        avatarUrl: 'https://example.com/avatar.jpg',
        status: UserStatus.active,
        statusMessage: 'Working on project',
        lastUpdated: now,
        isCurrentUser: true,
      );

      final json = session.toJson();
      final decoded = SessionInfo.fromJson(json);

      expect(decoded.id, '123');
      expect(decoded.username, 'testUser');
      expect(decoded.status, UserStatus.active);
      expect(decoded.isCurrentUser, true);
    });

    test('Task serialization', () {
      final now = DateTime.now();
      final task = Task(
        id: '456',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: now,
        updatedAt: now,
        priority: 5,
        assignees: ['user1', 'user2'],
      );

      final json = task.toJson();
      final decoded = Task.fromJson(json);

      expect(decoded.id, '456');
      expect(decoded.title, 'Test Task');
      expect(decoded.priority, 5);
      expect(decoded.assignees, ['user1', 'user2']);
    });

    test('Project serialization', () {
      final now = DateTime.now();
      final task = Task(
        id: '789',
        title: 'Project Task',
        description: 'Task Description',
        createdAt: now,
        updatedAt: now,
      );

      final project = Project(
        id: '999',
        name: 'Test Project',
        description: 'Project Description',
        tasks: [task],
        teamMembers: ['user1'],
        createdAt: now,
        updatedAt: now,
      );

      final json = project.toJson();
      final decoded = Project.fromJson(json);

      expect(decoded.id, '999');
      expect(decoded.name, 'Test Project');
      expect(decoded.tasks.length, 1);
      expect(decoded.tasks.first.id, '789');
      expect(decoded.teamMembers, ['user1']);
    });
  });
} 