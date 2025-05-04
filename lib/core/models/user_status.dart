import 'package:freezed_annotation/freezed_annotation.dart';

/// Represents the current status of a user in the system
@JsonEnum()
enum UserStatus {
  /// User is actively working
  @JsonValue('active')
  active,

  /// User is temporarily away
  @JsonValue('away')
  away,

  /// User is in a focus session
  @JsonValue('focusing')
  focusing,

  /// User is in a meeting
  @JsonValue('inMeeting')
  inMeeting,

  /// User is offline
  @JsonValue('offline')
  offline;

  /// Convert the enum to a string representation
  String toJson() => _$UserStatusEnumMap[this]!;

  /// Create a UserStatus from a string
  static UserStatus fromJson(String json) =>
      _$UserStatusEnumMap.entries.firstWhere(
        (entry) => entry.value == json,
        orElse: () => const MapEntry(UserStatus.offline, 'offline'),
      ).key;
}

/// Generated enum map for UserStatus
const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.away: 'away',
  UserStatus.focusing: 'focusing',
  UserStatus.inMeeting: 'inMeeting',
  UserStatus.offline: 'offline',
};

/// Top-level function for enum serialization (for use in @JsonKey)
String userStatusToJson(UserStatus status) => status.toJson(); 