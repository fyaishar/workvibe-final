import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_status.dart';

/// Represents a user in the system.
class User {
  /// Unique identifier for the user
  final String id;
  
  /// Username for display purposes
  final String username;
  
  /// Email address of the user
  final String email;
  
  /// URL to the user's avatar image
  final String avatarUrl;
  
  /// Current status of the user
  final UserStatus status;

  /// Optional status message set by the user
  final String? statusMessage;
  
  /// Current session ID if user is active
  final String? currentSession;
  
  /// Creation timestamp
  final DateTime createdAt;
  
  /// Last update timestamp
  final DateTime updatedAt;

  const User({
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

  /// Create a User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String? ?? 
        'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
      status: UserStatus.fromJson(json['status'] as String? ?? 'idle'),
      statusMessage: json['status_message'] as String?,
      currentSession: json['current_session'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert User instance to JSON
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

  /// Create a copy of this User with optional field updates
  User copyWith({
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
    return User(
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