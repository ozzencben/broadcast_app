// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 int get id; String get email; String get username;@JsonKey(name: 'first_name') String? get firstName;@JsonKey(name: 'last_name') String? get lastName; Gender get gender;@JsonKey(name: 'birth_date') DateTime? get birthDate; String? get bio;@JsonKey(name: 'profile_image_url') String? get profileImageUrl;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_admin') bool get isAdmin;@JsonKey(name: 'is_streamer') bool get isStreamer;@JsonKey(name: 'is_verified_streamer') bool get isVerifiedStreamer;// --- YENİ EKLENEN SOSYAL ALANLAR ---
@JsonKey(name: 'followers_count') int get followersCount;@JsonKey(name: 'following_count') int get followingCount;@JsonKey(name: 'is_following') bool get isFollowing;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isStreamer, isStreamer) || other.isStreamer == isStreamer)&&(identical(other.isVerifiedStreamer, isVerifiedStreamer) || other.isVerifiedStreamer == isVerifiedStreamer)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,firstName,lastName,gender,birthDate,bio,profileImageUrl,isActive,isAdmin,isStreamer,isVerifiedStreamer,followersCount,followingCount,isFollowing);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, username: $username, firstName: $firstName, lastName: $lastName, gender: $gender, birthDate: $birthDate, bio: $bio, profileImageUrl: $profileImageUrl, isActive: $isActive, isAdmin: $isAdmin, isStreamer: $isStreamer, isVerifiedStreamer: $isVerifiedStreamer, followersCount: $followersCount, followingCount: $followingCount, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 int id, String email, String username,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName, Gender gender,@JsonKey(name: 'birth_date') DateTime? birthDate, String? bio,@JsonKey(name: 'profile_image_url') String? profileImageUrl,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_admin') bool isAdmin,@JsonKey(name: 'is_streamer') bool isStreamer,@JsonKey(name: 'is_verified_streamer') bool isVerifiedStreamer,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'is_following') bool isFollowing
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? gender = null,Object? birthDate = freezed,Object? bio = freezed,Object? profileImageUrl = freezed,Object? isActive = null,Object? isAdmin = null,Object? isStreamer = null,Object? isVerifiedStreamer = null,Object? followersCount = null,Object? followingCount = null,Object? isFollowing = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isStreamer: null == isStreamer ? _self.isStreamer : isStreamer // ignore: cast_nullable_to_non_nullable
as bool,isVerifiedStreamer: null == isVerifiedStreamer ? _self.isVerifiedStreamer : isVerifiedStreamer // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String email,  String username, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName,  Gender gender, @JsonKey(name: 'birth_date')  DateTime? birthDate,  String? bio, @JsonKey(name: 'profile_image_url')  String? profileImageUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'is_streamer')  bool isStreamer, @JsonKey(name: 'is_verified_streamer')  bool isVerifiedStreamer, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'is_following')  bool isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.gender,_that.birthDate,_that.bio,_that.profileImageUrl,_that.isActive,_that.isAdmin,_that.isStreamer,_that.isVerifiedStreamer,_that.followersCount,_that.followingCount,_that.isFollowing);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String email,  String username, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName,  Gender gender, @JsonKey(name: 'birth_date')  DateTime? birthDate,  String? bio, @JsonKey(name: 'profile_image_url')  String? profileImageUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'is_streamer')  bool isStreamer, @JsonKey(name: 'is_verified_streamer')  bool isVerifiedStreamer, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'is_following')  bool isFollowing)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.gender,_that.birthDate,_that.bio,_that.profileImageUrl,_that.isActive,_that.isAdmin,_that.isStreamer,_that.isVerifiedStreamer,_that.followersCount,_that.followingCount,_that.isFollowing);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String email,  String username, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName,  Gender gender, @JsonKey(name: 'birth_date')  DateTime? birthDate,  String? bio, @JsonKey(name: 'profile_image_url')  String? profileImageUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'is_streamer')  bool isStreamer, @JsonKey(name: 'is_verified_streamer')  bool isVerifiedStreamer, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'is_following')  bool isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.gender,_that.birthDate,_that.bio,_that.profileImageUrl,_that.isActive,_that.isAdmin,_that.isStreamer,_that.isVerifiedStreamer,_that.followersCount,_that.followingCount,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.email, required this.username, @JsonKey(name: 'first_name') this.firstName, @JsonKey(name: 'last_name') this.lastName, required this.gender, @JsonKey(name: 'birth_date') this.birthDate, this.bio, @JsonKey(name: 'profile_image_url') this.profileImageUrl, @JsonKey(name: 'is_active') required this.isActive, @JsonKey(name: 'is_admin') required this.isAdmin, @JsonKey(name: 'is_streamer') required this.isStreamer, @JsonKey(name: 'is_verified_streamer') required this.isVerifiedStreamer, @JsonKey(name: 'followers_count') this.followersCount = 0, @JsonKey(name: 'following_count') this.followingCount = 0, @JsonKey(name: 'is_following') this.isFollowing = false});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  int id;
@override final  String email;
@override final  String username;
@override@JsonKey(name: 'first_name') final  String? firstName;
@override@JsonKey(name: 'last_name') final  String? lastName;
@override final  Gender gender;
@override@JsonKey(name: 'birth_date') final  DateTime? birthDate;
@override final  String? bio;
@override@JsonKey(name: 'profile_image_url') final  String? profileImageUrl;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_admin') final  bool isAdmin;
@override@JsonKey(name: 'is_streamer') final  bool isStreamer;
@override@JsonKey(name: 'is_verified_streamer') final  bool isVerifiedStreamer;
// --- YENİ EKLENEN SOSYAL ALANLAR ---
@override@JsonKey(name: 'followers_count') final  int followersCount;
@override@JsonKey(name: 'following_count') final  int followingCount;
@override@JsonKey(name: 'is_following') final  bool isFollowing;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isStreamer, isStreamer) || other.isStreamer == isStreamer)&&(identical(other.isVerifiedStreamer, isVerifiedStreamer) || other.isVerifiedStreamer == isVerifiedStreamer)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,firstName,lastName,gender,birthDate,bio,profileImageUrl,isActive,isAdmin,isStreamer,isVerifiedStreamer,followersCount,followingCount,isFollowing);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, username: $username, firstName: $firstName, lastName: $lastName, gender: $gender, birthDate: $birthDate, bio: $bio, profileImageUrl: $profileImageUrl, isActive: $isActive, isAdmin: $isAdmin, isStreamer: $isStreamer, isVerifiedStreamer: $isVerifiedStreamer, followersCount: $followersCount, followingCount: $followingCount, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String email, String username,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName, Gender gender,@JsonKey(name: 'birth_date') DateTime? birthDate, String? bio,@JsonKey(name: 'profile_image_url') String? profileImageUrl,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_admin') bool isAdmin,@JsonKey(name: 'is_streamer') bool isStreamer,@JsonKey(name: 'is_verified_streamer') bool isVerifiedStreamer,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'is_following') bool isFollowing
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? gender = null,Object? birthDate = freezed,Object? bio = freezed,Object? profileImageUrl = freezed,Object? isActive = null,Object? isAdmin = null,Object? isStreamer = null,Object? isVerifiedStreamer = null,Object? followersCount = null,Object? followingCount = null,Object? isFollowing = null,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isStreamer: null == isStreamer ? _self.isStreamer : isStreamer // ignore: cast_nullable_to_non_nullable
as bool,isVerifiedStreamer: null == isVerifiedStreamer ? _self.isVerifiedStreamer : isVerifiedStreamer // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
