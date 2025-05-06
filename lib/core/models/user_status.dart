import 'package:freezed_annotation/freezed_annotation.dart';

/// Represents the current status of a user in the system
@JsonEnum()
enum UserStatus {
  /// User is actively working
  @JsonValue('active')
  active,

  /// User is temporarily paused/away
  @JsonValue('paused')
  paused,

  /// User is idle/inactive
  @JsonValue('idle')
  idle;

  /// Convert the enum to a string representation
  String toJson() => _$UserStatusEnumMap[this]!;

  /// Create a UserStatus from a string
  static UserStatus fromJson(String json) =>
      _$UserStatusEnumMap.entries.firstWhere(
        (entry) => entry.value == json,
        orElse: () => const MapEntry(UserStatus.idle, 'idle'),
      ).key;
}

/// Generated enum map for UserStatus
const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.paused: 'paused',
  UserStatus.idle: 'idle',
};

/// Top-level function for enum serialization (for use in @JsonKey)
String userStatusToJson(UserStatus status) => status.toJson(); 