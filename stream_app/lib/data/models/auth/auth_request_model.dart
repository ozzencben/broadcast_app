import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request_model.freezed.dart';
part 'auth_request_model.g.dart';

@freezed
abstract class AuthRequestModel with _$AuthRequestModel {
  const factory AuthRequestModel({
    required String email,
    required String password,
  }) = _AuthRequestModel;

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestModelFromJson(json);
}