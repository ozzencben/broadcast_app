import 'package:stream_app/data/models/user/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stream_model.freezed.dart';
part 'stream_model.g.dart';

@freezed
abstract class StreamModel with _$StreamModel {
  const factory StreamModel({
    required String id,
    required int streamerId, // build.yaml sayesinde otomatik 'streamer_id' olur
    required String roomName, // 'room_name' olarak eşleşir
    required String title,
    required bool isLive, // 'is_live' olarak eşleşir
    required int viewerCount, // 'viewer_count' olarak eşleşir
    required DateTime createdAt, // 'created_at' olarak eşleşir
    UserModel? streamer, // Opsiyonel yaptık ki eksik veride liste patlamasın
  }) = _StreamModel;

  factory StreamModel.fromJson(Map<String, dynamic> json) =>
      _$StreamModelFromJson(json);
}

@freezed
abstract class StreamConnectionResponse with _$StreamConnectionResponse {
  const factory StreamConnectionResponse({
    required StreamModel stream,
    required String token,
  }) = _StreamConnectionResponse;

  factory StreamConnectionResponse.fromJson(Map<String, dynamic> json) =>
      _$StreamConnectionResponseFromJson(json);
}
