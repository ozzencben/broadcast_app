import 'package:dio/dio.dart';
import 'package:stream_app/data/models/stream/stream_model.dart';

abstract class StreamRemoteDataSource {
  Future<List<StreamModel>> getActiveStreams({int skip = 0, int limit = 10});
  Future<StreamConnectionResponse> startStream(String title);
  Future<StreamConnectionResponse> joinStream(String roomName);
  Future<void> endStream(String roomName);
}

class StreamRemoteDataSourceImpl implements StreamRemoteDataSource {
  final Dio dio;
  StreamRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StreamModel>> getActiveStreams({
    int skip = 0,
    int limit = 10,
  }) async {
    final response = await dio.get(
      '/streams/active',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return (response.data as List)
        .map((json) => StreamModel.fromJson(json))
        .toList();
  }

  @override
  Future<StreamConnectionResponse> startStream(String title) async {
    final response = await dio.post('/streams/start', data: {'title': title});
    return StreamConnectionResponse.fromJson(response.data);
  }

  @override
  Future<StreamConnectionResponse> joinStream(String roomName) async {
    final response = await dio.get('/streams/$roomName/join');
    return StreamConnectionResponse.fromJson(response.data);
  }

  @override
  Future<void> endStream(String roomName) async {
    await dio.post('/streams/$roomName/end');
  }
}
