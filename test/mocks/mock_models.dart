import 'package:finalworkvibe/core/models/user_status.dart';

/// Mock User model for testing
class MockUser {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final UserStatus status;
  final String? statusMessage;
  final String? currentSession;
  final DateTime createdAt;
  final DateTime updatedAt;

  MockUser({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl = 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
    this.status = UserStatus.idle,
    this.statusMessage,
    this.currentSession,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MockUser.fromJson(Map<String, dynamic> json) {
    return MockUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String? ?? 
        'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
      status: UserStatus.fromJson(json['status'] as String),
      statusMessage: json['status_message'] as String?,
      currentSession: json['current_session'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'status': status.toJson(),
      'status_message': statusMessage,
      'current_session': currentSession,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MockUser copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    UserStatus? status,
    String? statusMessage,
    String? currentSession,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MockUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      currentSession: currentSession ?? this.currentSession,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Mock Task model for testing
class MockTask {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime? dueDate;
  final String? assignedTo;
  final String? projectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MockTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    this.assignedTo,
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MockTask.fromJson(Map<String, dynamic> json) {
    return MockTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      assignedTo: json['assigned_to'] as String?,
      projectId: json['project_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'assigned_to': assignedTo,
      'project_id': projectId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MockTask copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    String? assignedTo,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MockTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 