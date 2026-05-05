// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_annotation_target

part of 'stream_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreamModel _$StreamModelFromJson(Map<String, dynamic> json) => _StreamModel(
  id: json['id'] as String,
  streamerId: (json['streamer_id'] as num).toInt(),
  roomName: json['room_name'] as String,
  title: json['title'] as String,
  isLive: json['is_live'] as bool,
  viewerCount: (json['viewer_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  streamer: json['streamer'] == null
      ? null
      : UserModel.fromJson(json['streamer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StreamModelToJson(_StreamModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'streamer_id': instance.streamerId,
      'room_name': instance.roomName,
      'title': instance.title,
      'is_live': instance.isLive,
      'viewer_count': instance.viewerCount,
      'created_at': instance.createdAt.toIso8601String(),
      'streamer': instance.streamer?.toJson(),
    };

_StreamConnectionResponse _$StreamConnectionResponseFromJson(
  Map<String, dynamic> json,
) => _StreamConnectionResponse(
  stream: StreamModel.fromJson(json['stream'] as Map<String, dynamic>),
  token: json['token'] as String,
);

Map<String, dynamic> _$StreamConnectionResponseToJson(
  _StreamConnectionResponse instance,
) => <String, dynamic>{
  'stream': instance.stream.toJson(),
  'token': instance.token,
};
