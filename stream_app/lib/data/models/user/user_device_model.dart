import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_device_model.freezed.dart';
part 'user_device_model.g.dart';

@freezed
abstract class UserDeviceModel with _$UserDeviceModel {
  const factory UserDeviceModel({
    int? id,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'fcm_token') required String fcmToken,
    @JsonKey(name: 'device_type') required String deviceType, // android, ios, web
    @JsonKey(name: 'device_model') String? deviceModel,
    @JsonKey(name: 'last_active') DateTime? lastActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserDeviceModel;

  factory UserDeviceModel.fromJson(Map<String, dynamic> json) =>
      _$UserDeviceModelFromJson(json);
}