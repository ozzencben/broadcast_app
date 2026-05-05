import 'dart:core';

import 'package:dio/dio.dart';
import '../models/user/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getMe();
  Future<UserModel> updateMe(Map<String, dynamic> data);
  Future<void> deactivateMe();
  Future<UserModel> uploadProfileImage(String filePath);
  Future<UserModel> getUserById(int userId);
  Future<List<UserModel>> searchUsers(String query);

  // --- TAKİP SİSTEMİ ---
  Future<void> followStreamer(int streamerId);
  Future<void> unfollowStreamer(int streamerId);
  Future<List<UserModel>> getFollowerList(int streamerId);
  Future<List<UserModel>> getFollowingList(int userId);

  // --- CIHAZ VE BILDIRIM ---
  /// FCM Token ve cihaz bilgilerini kaydeder (204 No Content bekler).
  Future<void> registerDevice(Map<String, dynamic> deviceData);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;
  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> getMe() async {
    final response = await dio.get('/users/me');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> updateMe(Map<String, dynamic> data) async {
    final response = await dio.patch('/users/me', data: data);
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> deactivateMe() async {
    await dio.delete('/users/me');
  }

  @override
  Future<UserModel> uploadProfileImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post(
      '/users/me/image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> getUserById(int userId) async {
    final response = await dio.get('/users/$userId');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await dio.get(
      '/users/search',
      queryParameters: {'q': query},
    );
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  // --- TAKİP SİSTEMİ ---

  @override
  Future<void> followStreamer(int streamerId) async {
    await dio.post('/users/$streamerId/follow');
  }

  @override
  Future<void> unfollowStreamer(int streamerId) async {
    await dio.post('/users/$streamerId/unfollow');
  }

  @override
  Future<List<UserModel>> getFollowerList(int streamerId) async {
    final response = await dio.get('/users/$streamerId/followers');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<UserModel>> getFollowingList(int userId) async {
    final response = await dio.get('/users/$userId/following');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> registerDevice(Map<String, dynamic> deviceData) async {
    await dio.post('/users/me/devices', data: deviceData);
  }
}
