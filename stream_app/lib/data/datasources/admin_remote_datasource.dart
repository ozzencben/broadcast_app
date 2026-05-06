import 'package:dio/dio.dart';
import 'package:stream_app/core/constants.dart';
import 'package:stream_app/data/models/user/user_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserModel>> getAllUsers({int skip = 0, int limit = 100});
  Future<UserModel> promoteToStreamer(int userId);
  Future<UserModel> toggleUserStatus(int userId);
  Future<UserModel> getUserDetails(int userId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio;
  AdminRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getAllUsers({int skip = 0, int limit = 100}) async {
    final response = await dio.get(
      ApiConstants.admin,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<UserModel> getUserDetails(int userId) async {
    final response = await dio.get('${ApiConstants.admin}/$userId');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> promoteToStreamer(int userId) async {
    final response = await dio.patch('${ApiConstants.admin}/$userId/promote-streamer');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> toggleUserStatus(int userId) async {
    final response = await dio.patch('${ApiConstants.admin}/$userId/toggle-status');
    return UserModel.fromJson(response.data);
  }
}
