// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_annotation_target

part of 'auth_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthRequestModel _$AuthRequestModelFromJson(Map<String, dynamic> json) =>
    _AuthRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$AuthRequestModelToJson(_AuthRequestModel instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};
