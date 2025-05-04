// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionInfoImpl _$$SessionInfoImplFromJson(Map<String, dynamic> json) =>
    _$SessionInfoImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      status: UserStatus.fromJson(json['status'] as String),
      statusMessage: json['statusMessage'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );

Map<String, dynamic> _$$SessionInfoImplToJson(_$SessionInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'status': userStatusToJson(instance.status),
      'statusMessage': instance.statusMessage,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'isCurrentUser': instance.isCurrentUser,
    };
