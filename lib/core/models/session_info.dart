import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_status.dart';

part 'session_info.freezed.dart';
part 'session_info.g.dart';

/// Represents information about a user's session
@freezed
class SessionInfo with _$SessionInfo {
  const factory SessionInfo({
    /// Unique identifier for the session
    required String id,
    
    /// User's display name
    required String username,
    
    /// URL to the user's avatar image
    required String avatarUrl,
    
    /// Current status of the user
    @JsonKey(
      unknownEnumValue: UserStatus.idle,
      toJson: userStatusToJson,
      fromJson: UserStatus.fromJson,
    )
    required UserStatus status,
    
    /// Optional status message set by the user
    String? statusMessage,
    
    /// Timestamp when the session was last updated
    required DateTime lastUpdated,
    
    /// Whether this is the current user's session
    @Default(false) bool isCurrentUser,
  }) = _SessionInfo;

  /// Create a SessionInfo instance from JSON
  factory SessionInfo.fromJson(Map<String, dynamic> json) =>
      _$SessionInfoFromJson(json);
} 