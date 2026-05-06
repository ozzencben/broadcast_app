import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stream_app/core/constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  // Refresh isteği için temiz (interceptor'suz) bir Dio instance'ı
  final Dio _tokenDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  AuthInterceptor(this.dio, this.secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Login ve Register endpoint'leri hariç tüm isteklere token ekle
    if (!options.path.contains(ApiConstants.login) &&
        !options.path.contains(ApiConstants.register)) {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. Giriş veya Kayıt denemesi 401 almışsa, refresh yapmak anlamsızdır (Şifre yanlıştır)
    final String path = err.requestOptions.path;
    if (path.contains(ApiConstants.login) || path.contains(ApiConstants.register)) {
      return super.onError(err, handler);
    }

    // 2. 401 Unauthorized yakalandı -> Access Token bitmiş olabilir
    if (err.response?.statusCode == 401) {
      final refreshToken = await secureStorage.read(key: 'refresh_token');

      if (refreshToken != null) {
        try {
          // Refresh isteğinin kendisi 401 alırsa sonsuz döngüye girmemek için check
          if (path.contains(ApiConstants.refresh)) {
            await secureStorage.deleteAll();
            return super.onError(err, handler);
          }

          // Backend'den yeni tokenları iste
          final response = await _tokenDio.post(
            ApiConstants.refresh,
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];

            // Yeni tokenları depoya yaz
            await secureStorage.write(
              key: 'access_token',
              value: newAccessToken,
            );
            await secureStorage.write(
              key: 'refresh_token',
              value: newRefreshToken,
            );

            // Başarısız olan asıl isteğin header'ını güncelle ve tekrarla
            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            final cloneReq = await dio.request(
              err.requestOptions.path,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            // Zinciri başarılı cevapla tamamla (UI bu hatayı hiç görmez)
            return handler.resolve(cloneReq);
          }
        } catch (e) {
          // Refresh token da patladıysa veya expire olduysa oturumu kapat
          await secureStorage.deleteAll();
          // TODO: İleride buraya EventBus veya Global Key ile Login ekranına yönlendirme eklenecek
          return super.onError(err, handler);
        }
      }
    }

    // 401 dışındaki diğer tüm hataları geçişe izin ver
    return super.onError(err, handler);
  }
}
