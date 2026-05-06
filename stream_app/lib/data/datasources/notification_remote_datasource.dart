import 'package:dio/dio.dart';
import 'package:stream_app/core/constants.dart';
import '../models/notification/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    int offset = 0,
  });
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;
  NotificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await dio.get(
      ApiConstants.notifications,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> markAsRead(int id) async {
    await dio.patch('${ApiConstants.notifications}/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await dio.patch('${ApiConstants.notifications}/read-all');
  }
}
