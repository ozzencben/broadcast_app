// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_annotation_target

part of 'user_device_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDeviceModel _$UserDeviceModelFromJson(Map<String, dynamic> json) =>
    _UserDeviceModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      fcmToken: json['fcm_token'] as String,
      deviceType: json['device_type'] as String,
      deviceModel: json['device_model'] as String?,
      lastActive: json['last_active'] == null
          ? null
          : DateTime.parse(json['last_active'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserDeviceModelToJson(_UserDeviceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'fcm_token': instance.fcmToken,
      'device_type': instance.deviceType,
      'device_model': instance.deviceModel,
      'last_active': instance.lastActive?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };
