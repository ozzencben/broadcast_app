// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_annotation_target

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  birthDate: json['birth_date'] == null
      ? null
      : DateTime.parse(json['birth_date'] as String),
  bio: json['bio'] as String?,
  profileImageUrl: json['profile_image_url'] as String?,
  isActive: json['is_active'] as bool,
  isAdmin: json['is_admin'] as bool,
  isStreamer: json['is_streamer'] as bool,
  isVerifiedStreamer: json['is_verified_streamer'] as bool,
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  isFollowing: json['is_following'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'gender': _$GenderEnumMap[instance.gender]!,
      'birth_date': instance.birthDate?.toIso8601String(),
      'bio': instance.bio,
      'profile_image_url': instance.profileImageUrl,
      'is_active': instance.isActive,
      'is_admin': instance.isAdmin,
      'is_streamer': instance.isStreamer,
      'is_verified_streamer': instance.isVerifiedStreamer,
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'is_following': instance.isFollowing,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
  Gender.preferNotToSay: 'prefer_not_to_say',
};
