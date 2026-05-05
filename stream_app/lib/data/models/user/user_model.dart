import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
  @JsonValue('prefer_not_to_say')
  preferNotToSay,
}

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String email,
    required String username,

    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,

    required Gender gender,

    @JsonKey(name: 'birth_date') DateTime? birthDate,

    String? bio,

    @JsonKey(name: 'profile_image_url') String? profileImageUrl,

    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'is_admin') required bool isAdmin,
    @JsonKey(name: 'is_streamer') required bool isStreamer,
    @JsonKey(name: 'is_verified_streamer') required bool isVerifiedStreamer,

    // --- YENİ EKLENEN SOSYAL ALANLAR ---
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
