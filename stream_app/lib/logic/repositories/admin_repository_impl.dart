import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:stream_app/core/failures.dart';
import 'package:stream_app/data/datasources/admin_remote_datasource.dart';
import 'package:stream_app/data/models/user/user_model.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<UserModel>>> getAllUsers({
    int skip = 0,
    int limit = 100,
  });
  Future<Either<Failure, UserModel>> promoteToStreamer(int userId);
  Future<Either<Failure, UserModel>> toggleUserStatus(int userId);
  Future<Either<Failure, UserModel>> getUserDetails(int userId);
}

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserModel>>> getAllUsers({
    int skip = 0,
    int limit = 100,
  }) async {
    return await _handleException(
      () => remoteDataSource.getAllUsers(skip: skip, limit: limit),
    );
  }

  @override
  Future<Either<Failure, UserModel>> getUserDetails(int userId) async {
    return await _handleException(
      () => remoteDataSource.getUserDetails(userId),
    );
  }

  @override
  Future<Either<Failure, UserModel>> promoteToStreamer(int userId) async {
    return await _handleException(
      () => remoteDataSource.promoteToStreamer(userId),
    );
  }

  @override
  Future<Either<Failure, UserModel>> toggleUserStatus(int userId) async {
    return await _handleException(
      () => remoteDataSource.toggleUserStatus(userId),
    );
  }

  Future<Either<Failure, T>> _handleException<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Admin işlemi başarısız';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
