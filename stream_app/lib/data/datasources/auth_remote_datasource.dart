import 'package:dio/dio.dart';
import '../models/auth/auth_request_model.dart';
import '../models/token/token_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenResponseModel> login(AuthRequestModel request);
  Future<TokenResponseModel> register(AuthRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<TokenResponseModel> login(AuthRequestModel request) async {
    // JSON yerine FormData objesi oluşturuyoruz
    final formData = FormData.fromMap({
      'username': request.email, // AuthRequestModel'indeki email/username alanı
      'password': request.password,
    });

    final response = await dio.post(
      '/auth/login',
      data: formData,
      options: Options(
        // Header'da içeriğin form verisi olduğunu belirtiyoruz
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return TokenResponseModel.fromJson(response.data);
  }

  @override
  Future<TokenResponseModel> register(AuthRequestModel request) async {
    final response = await dio.post('/auth/register', data: request.toJson());
    return TokenResponseModel.fromJson(response.data);
  }
}
