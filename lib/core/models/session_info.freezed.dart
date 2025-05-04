// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SessionInfo _$SessionInfoFromJson(Map<String, dynamic> json) {
  return _SessionInfo.fromJson(json);
}

/// @nodoc
mixin _$SessionInfo {
  /// Unique identifier for the session
  String get id => throw _privateConstructorUsedError;

  /// User's display name
  String get username => throw _privateConstructorUsedError;

  /// URL to the user's avatar image
  String get avatarUrl => throw _privateConstructorUsedError;

  /// Current status of the user
  @JsonKey(
    unknownEnumValue: UserStatus.offline,
    toJson: userStatusToJson,
    fromJson: UserStatus.fromJson,
  )
  UserStatus get status => throw _privateConstructorUsedError;

  /// Optional status message set by the user
  String? get statusMessage => throw _privateConstructorUsedError;

  /// Timestamp when the session was last updated
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Whether this is the current user's session
  bool get isCurrentUser => throw _privateConstructorUsedError;

  /// Serializes this SessionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionInfoCopyWith<SessionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionInfoCopyWith<$Res> {
  factory $SessionInfoCopyWith(
    SessionInfo value,
    $Res Function(SessionInfo) then,
  ) = _$SessionInfoCopyWithImpl<$Res, SessionInfo>;
  @useResult
  $Res call({
    String id,
    String username,
    String avatarUrl,
    @JsonKey(
      unknownEnumValue: UserStatus.offline,
      toJson: userStatusToJson,
      fromJson: UserStatus.fromJson,
    )
    UserStatus status,
    String? statusMessage,
    DateTime lastUpdated,
    bool isCurrentUser,
  });
}

/// @nodoc
class _$SessionInfoCopyWithImpl<$Res, $Val extends SessionInfo>
    implements $SessionInfoCopyWith<$Res> {
  _$SessionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? avatarUrl = null,
    Object? status = null,
    Object? statusMessage = freezed,
    Object? lastUpdated = null,
    Object? isCurrentUser = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            avatarUrl:
                null == avatarUrl
                    ? _value.avatarUrl
                    : avatarUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as UserStatus,
            statusMessage:
                freezed == statusMessage
                    ? _value.statusMessage
                    : statusMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastUpdated:
                null == lastUpdated
                    ? _value.lastUpdated
                    : lastUpdated // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            isCurrentUser:
                null == isCurrentUser
                    ? _value.isCurrentUser
                    : isCurrentUser // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionInfoImplCopyWith<$Res>
    implements $SessionInfoCopyWith<$Res> {
  factory _$$SessionInfoImplCopyWith(
    _$SessionInfoImpl value,
    $Res Function(_$SessionInfoImpl) then,
  ) = __$$SessionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    String avatarUrl,
    @JsonKey(
      unknownEnumValue: UserStatus.offline,
      toJson: userStatusToJson,
      fromJson: UserStatus.fromJson,
    )
    UserStatus status,
    String? statusMessage,
    DateTime lastUpdated,
    bool isCurrentUser,
  });
}

/// @nodoc
class __$$SessionInfoImplCopyWithImpl<$Res>
    extends _$SessionInfoCopyWithImpl<$Res, _$SessionInfoImpl>
    implements _$$SessionInfoImplCopyWith<$Res> {
  __$$SessionInfoImplCopyWithImpl(
    _$SessionInfoImpl _value,
    $Res Function(_$SessionInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? avatarUrl = null,
    Object? status = null,
    Object? statusMessage = freezed,
    Object? lastUpdated = null,
    Object? isCurrentUser = null,
  }) {
    return _then(
      _$SessionInfoImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        avatarUrl:
            null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as UserStatus,
        statusMessage:
            freezed == statusMessage
                ? _value.statusMessage
                : statusMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastUpdated:
            null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        isCurrentUser:
            null == isCurrentUser
                ? _value.isCurrentUser
                : isCurrentUser // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionInfoImpl implements _SessionInfo {
  const _$SessionInfoImpl({
    required this.id,
    required this.username,
    required this.avatarUrl,
    @JsonKey(
      unknownEnumValue: UserStatus.offline,
      toJson: userStatusToJson,
      fromJson: UserStatus.fromJson,
    )
    required this.status,
    this.statusMessage,
    required this.lastUpdated,
    this.isCurrentUser = false,
  });

  factory _$SessionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionInfoImplFromJson(json);

  /// Unique identifier for the session
  @override
  final String id;

  /// User's display name
  @override
  final String username;

  /// URL to the user's avatar image
  @override
  final String avatarUrl;

  /// Current status of the user
  @override
  @JsonKey(
    unknownEnumValue: UserStatus.offline,
    toJson: userStatusToJson,
    fromJson: UserStatus.fromJson,
  )
  final UserStatus status;

  /// Optional status message set by the user
  @override
  final String? statusMessage;

  /// Timestamp when the session was last updated
  @override
  final DateTime lastUpdated;

  /// Whether this is the current user's session
  @override
  @JsonKey()
  final bool isCurrentUser;

  @override
  String toString() {
    return 'SessionInfo(id: $id, username: $username, avatarUrl: $avatarUrl, status: $status, statusMessage: $statusMessage, lastUpdated: $lastUpdated, isCurrentUser: $isCurrentUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.isCurrentUser, isCurrentUser) ||
                other.isCurrentUser == isCurrentUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    avatarUrl,
    status,
    statusMessage,
    lastUpdated,
    isCurrentUser,
  );

  /// Create a copy of SessionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionInfoImplCopyWith<_$SessionInfoImpl> get copyWith =>
      __$$SessionInfoImplCopyWithImpl<_$SessionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionInfoImplToJson(this);
  }
}

abstract class _SessionInfo implements SessionInfo {
  const factory _SessionInfo({
    required final String id,
    required final String username,
    required final String avatarUrl,
    @JsonKey(
      unknownEnumValue: UserStatus.offline,
      toJson: userStatusToJson,
      fromJson: UserStatus.fromJson,
    )
    required final UserStatus status,
    final String? statusMessage,
    required final DateTime lastUpdated,
    final bool isCurrentUser,
  }) = _$SessionInfoImpl;

  factory _SessionInfo.fromJson(Map<String, dynamic> json) =
      _$SessionInfoImpl.fromJson;

  /// Unique identifier for the session
  @override
  String get id;

  /// User's display name
  @override
  String get username;

  /// URL to the user's avatar image
  @override
  String get avatarUrl;

  /// Current status of the user
  @override
  @JsonKey(
    unknownEnumValue: UserStatus.offline,
    toJson: userStatusToJson,
    fromJson: UserStatus.fromJson,
  )
  UserStatus get status;

  /// Optional status message set by the user
  @override
  String? get statusMessage;

  /// Timestamp when the session was last updated
  @override
  DateTime get lastUpdated;

  /// Whether this is the current user's session
  @override
  bool get isCurrentUser;

  /// Create a copy of SessionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionInfoImplCopyWith<_$SessionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
