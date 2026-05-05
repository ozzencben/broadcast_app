import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stream_app/core/failures.dart';
import 'package:stream_app/data/datasources/auth_remote_datasource.dart';
import 'package:stream_app/data/models/auth/auth_request_model.dart';
import 'package:stream_app/data/models/token/token_response_model.dart';


abstract class AuthRepository {
  Future<Either<Failure, TokenResponseModel>> login(AuthRequestModel request);
  Future<Either<Failure, TokenResponseModel>> register(AuthRequestModel request);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, TokenResponseModel>> login(AuthRequestModel request) async {
    return _handleAuth(() => remoteDataSource.login(request));
  }

  @override
  Future<Either<Failure, TokenResponseModel>> register(AuthRequestModel request) async {
    return _handleAuth(() => remoteDataSource.register(request));
  }

  // Ortak hata yönetimi ve token kaydetme mantığı
  Future<Either<Failure, TokenResponseModel>> _handleAuth(
    Future<TokenResponseModel> Function() action,
  ) async {
    try {
      final result = await action();
      
      // Token'ları güvenli depoya kaydet
      await secureStorage.write(key: 'access_token', value: result.accessToken);
      await secureStorage.write(key: 'refresh_token', value: result.refreshToken);
      
      return Right(result);
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['detail'] ?? 'Sunucu hatası oluştu';
        return Left(ServerFailure(message));
      }
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}