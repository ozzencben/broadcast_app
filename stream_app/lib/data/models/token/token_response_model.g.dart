// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_annotation_target

part of 'token_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenResponseModel _$TokenResponseModelFromJson(Map<String, dynamic> json) =>
    _TokenResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TokenResponseModelToJson(_TokenResponseModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'user': instance.user.toJson(),
    };
