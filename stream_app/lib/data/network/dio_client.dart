import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;
  final FlutterSecureStorage secureStorage;

  DioClient(this.secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.1.107:8000/api',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        responseType: ResponseType.json,
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    // Auth Interceptor'ı bağlıyoruz
    dio.interceptors.add(AuthInterceptor(dio, secureStorage));

    // Sadece Debug modda (geliştirme aşamasında) istekleri terminale basar
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => print(obj.toString()),
        ),
      );
    }
  }
}
