// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stream_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreamModel {

 String get id; int get streamerId;// build.yaml sayesinde otomatik 'streamer_id' olur
 String get roomName;// 'room_name' olarak eşleşir
 String get title; bool get isLive;// 'is_live' olarak eşleşir
 int get viewerCount;// 'viewer_count' olarak eşleşir
 DateTime get createdAt;// 'created_at' olarak eşleşir
 UserModel? get streamer;
/// Create a copy of StreamModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamModelCopyWith<StreamModel> get copyWith => _$StreamModelCopyWithImpl<StreamModel>(this as StreamModel, _$identity);

  /// Serializes this StreamModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.title, title) || other.title == title)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.streamer, streamer) || other.streamer == streamer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,streamerId,roomName,title,isLive,viewerCount,createdAt,streamer);

@override
String toString() {
  return 'StreamModel(id: $id, streamerId: $streamerId, roomName: $roomName, title: $title, isLive: $isLive, viewerCount: $viewerCount, createdAt: $createdAt, streamer: $streamer)';
}


}

/// @nodoc
abstract mixin class $StreamModelCopyWith<$Res>  {
  factory $StreamModelCopyWith(StreamModel value, $Res Function(StreamModel) _then) = _$StreamModelCopyWithImpl;
@useResult
$Res call({
 String id, int streamerId, String roomName, String title, bool isLive, int viewerCount, DateTime createdAt, UserModel? streamer
});


$UserModelCopyWith<$Res>? get streamer;

}
/// @nodoc
class _$StreamModelCopyWithImpl<$Res>
    implements $StreamModelCopyWith<$Res> {
  _$StreamModelCopyWithImpl(this._self, this._then);

  final StreamModel _self;
  final $Res Function(StreamModel) _then;

/// Create a copy of StreamModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? streamerId = null,Object? roomName = null,Object? title = null,Object? isLive = null,Object? viewerCount = null,Object? createdAt = null,Object? streamer = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as int,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,streamer: freezed == streamer ? _self.streamer : streamer // ignore: cast_nullable_to_non_nullable
as UserModel?,
  ));
}
/// Create a copy of StreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res>? get streamer {
    if (_self.streamer == null) {
    return null;
  }

  return $UserModelCopyWith<$Res>(_self.streamer!, (value) {
    return _then(_self.copyWith(streamer: value));
  });
}
}


/// Adds pattern-matching-related methods to [StreamModel].
extension StreamModelPatterns on StreamModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamModel value)  $default,){
final _that = this;
switch (_that) {
case _StreamModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamModel value)?  $default,){
final _that = this;
switch (_that) {
case _StreamModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int streamerId,  String roomName,  String title,  bool isLive,  int viewerCount,  DateTime createdAt,  UserModel? streamer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamModel() when $default != null:
return $default(_that.id,_that.streamerId,_that.roomName,_that.title,_that.isLive,_that.viewerCount,_that.createdAt,_that.streamer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int streamerId,  String roomName,  String title,  bool isLive,  int viewerCount,  DateTime createdAt,  UserModel? streamer)  $default,) {final _that = this;
switch (_that) {
case _StreamModel():
return $default(_that.id,_that.streamerId,_that.roomName,_that.title,_that.isLive,_that.viewerCount,_that.createdAt,_that.streamer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int streamerId,  String roomName,  String title,  bool isLive,  int viewerCount,  DateTime createdAt,  UserModel? streamer)?  $default,) {final _that = this;
switch (_that) {
case _StreamModel() when $default != null:
return $default(_that.id,_that.streamerId,_that.roomName,_that.title,_that.isLive,_that.viewerCount,_that.createdAt,_that.streamer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamModel implements StreamModel {
  const _StreamModel({required this.id, required this.streamerId, required this.roomName, required this.title, required this.isLive, required this.viewerCount, required this.createdAt, this.streamer});
  factory _StreamModel.fromJson(Map<String, dynamic> json) => _$StreamModelFromJson(json);

@override final  String id;
@override final  int streamerId;
// build.yaml sayesinde otomatik 'streamer_id' olur
@override final  String roomName;
// 'room_name' olarak eşleşir
@override final  String title;
@override final  bool isLive;
// 'is_live' olarak eşleşir
@override final  int viewerCount;
// 'viewer_count' olarak eşleşir
@override final  DateTime createdAt;
// 'created_at' olarak eşleşir
@override final  UserModel? streamer;

/// Create a copy of StreamModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamModelCopyWith<_StreamModel> get copyWith => __$StreamModelCopyWithImpl<_StreamModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamModel&&(identical(other.id, id) || other.id == id)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.title, title) || other.title == title)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.streamer, streamer) || other.streamer == streamer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,streamerId,roomName,title,isLive,viewerCount,createdAt,streamer);

@override
String toString() {
  return 'StreamModel(id: $id, streamerId: $streamerId, roomName: $roomName, title: $title, isLive: $isLive, viewerCount: $viewerCount, createdAt: $createdAt, streamer: $streamer)';
}


}

/// @nodoc
abstract mixin class _$StreamModelCopyWith<$Res> implements $StreamModelCopyWith<$Res> {
  factory _$StreamModelCopyWith(_StreamModel value, $Res Function(_StreamModel) _then) = __$StreamModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int streamerId, String roomName, String title, bool isLive, int viewerCount, DateTime createdAt, UserModel? streamer
});


@override $UserModelCopyWith<$Res>? get streamer;

}
/// @nodoc
class __$StreamModelCopyWithImpl<$Res>
    implements _$StreamModelCopyWith<$Res> {
  __$StreamModelCopyWithImpl(this._self, this._then);

  final _StreamModel _self;
  final $Res Function(_StreamModel) _then;

/// Create a copy of StreamModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? streamerId = null,Object? roomName = null,Object? title = null,Object? isLive = null,Object? viewerCount = null,Object? createdAt = null,Object? streamer = freezed,}) {
  return _then(_StreamModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as int,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,streamer: freezed == streamer ? _self.streamer : streamer // ignore: cast_nullable_to_non_nullable
as UserModel?,
  ));
}

/// Create a copy of StreamModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res>? get streamer {
    if (_self.streamer == null) {
    return null;
  }

  return $UserModelCopyWith<$Res>(_self.streamer!, (value) {
    return _then(_self.copyWith(streamer: value));
  });
}
}


/// @nodoc
mixin _$StreamConnectionResponse {

 StreamModel get stream; String get token;
/// Create a copy of StreamConnectionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamConnectionResponseCopyWith<StreamConnectionResponse> get copyWith => _$StreamConnectionResponseCopyWithImpl<StreamConnectionResponse>(this as StreamConnectionResponse, _$identity);

  /// Serializes this StreamConnectionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamConnectionResponse&&(identical(other.stream, stream) || other.stream == stream)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stream,token);

@override
String toString() {
  return 'StreamConnectionResponse(stream: $stream, token: $token)';
}


}

/// @nodoc
abstract mixin class $StreamConnectionResponseCopyWith<$Res>  {
  factory $StreamConnectionResponseCopyWith(StreamConnectionResponse value, $Res Function(StreamConnectionResponse) _then) = _$StreamConnectionResponseCopyWithImpl;
@useResult
$Res call({
 StreamModel stream, String token
});


$StreamModelCopyWith<$Res> get stream;

}
/// @nodoc
class _$StreamConnectionResponseCopyWithImpl<$Res>
    implements $StreamConnectionResponseCopyWith<$Res> {
  _$StreamConnectionResponseCopyWithImpl(this._self, this._then);

  final StreamConnectionResponse _self;
  final $Res Function(StreamConnectionResponse) _then;

/// Create a copy of StreamConnectionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stream = null,Object? token = null,}) {
  return _then(_self.copyWith(
stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as StreamModel,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of StreamConnectionResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamModelCopyWith<$Res> get stream {
  
  return $StreamModelCopyWith<$Res>(_self.stream, (value) {
    return _then(_self.copyWith(stream: value));
  });
}
}


/// Adds pattern-matching-related methods to [StreamConnectionResponse].
extension StreamConnectionResponsePatterns on StreamConnectionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamConnectionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamConnectionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamConnectionResponse value)  $default,){
final _that = this;
switch (_that) {
case _StreamConnectionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamConnectionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _StreamConnectionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StreamModel stream,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamConnectionResponse() when $default != null:
return $default(_that.stream,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StreamModel stream,  String token)  $default,) {final _that = this;
switch (_that) {
case _StreamConnectionResponse():
return $default(_that.stream,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StreamModel stream,  String token)?  $default,) {final _that = this;
switch (_that) {
case _StreamConnectionResponse() when $default != null:
return $default(_that.stream,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamConnectionResponse implements StreamConnectionResponse {
  const _StreamConnectionResponse({required this.stream, required this.token});
  factory _StreamConnectionResponse.fromJson(Map<String, dynamic> json) => _$StreamConnectionResponseFromJson(json);

@override final  StreamModel stream;
@override final  String token;

/// Create a copy of StreamConnectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamConnectionResponseCopyWith<_StreamConnectionResponse> get copyWith => __$StreamConnectionResponseCopyWithImpl<_StreamConnectionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamConnectionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamConnectionResponse&&(identical(other.stream, stream) || other.stream == stream)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stream,token);

@override
String toString() {
  return 'StreamConnectionResponse(stream: $stream, token: $token)';
}


}

/// @nodoc
abstract mixin class _$StreamConnectionResponseCopyWith<$Res> implements $StreamConnectionResponseCopyWith<$Res> {
  factory _$StreamConnectionResponseCopyWith(_StreamConnectionResponse value, $Res Function(_StreamConnectionResponse) _then) = __$StreamConnectionResponseCopyWithImpl;
@override @useResult
$Res call({
 StreamModel stream, String token
});


@override $StreamModelCopyWith<$Res> get stream;

}
/// @nodoc
class __$StreamConnectionResponseCopyWithImpl<$Res>
    implements _$StreamConnectionResponseCopyWith<$Res> {
  __$StreamConnectionResponseCopyWithImpl(this._self, this._then);

  final _StreamConnectionResponse _self;
  final $Res Function(_StreamConnectionResponse) _then;

/// Create a copy of StreamConnectionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stream = null,Object? token = null,}) {
  return _then(_StreamConnectionResponse(
stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as StreamModel,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of StreamConnectionResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamModelCopyWith<$Res> get stream {
  
  return $StreamModelCopyWith<$Res>(_self.stream, (value) {
    return _then(_self.copyWith(stream: value));
  });
}
}

// dart format on
