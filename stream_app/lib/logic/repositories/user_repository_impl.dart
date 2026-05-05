import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:stream_app/core/failures.dart';
import 'package:stream_app/data/datasources/user_remote_datasource.dart';
import 'package:stream_app/data/models/user/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel>> getMe();
  Future<Either<Failure, UserModel>> updateMe(Map<String, dynamic> data);
  Future<Either<Failure, void>> deactivateMe();
  Future<Either<Failure, UserModel>> uploadProfileImage(String filePath);
  Future<Either<Failure, UserModel>> getUserById(int userId);
  Future<Either<Failure, List<UserModel>>> searchUsers(String query);

  // --- TAKİP SİSTEMİ ---
  Future<Either<Failure, void>> followStreamer(int streamerId);
  Future<Either<Failure, void>> unfollowStreamer(int streamerId);
  Future<Either<Failure, List<UserModel>>> getFollowerList(int streamerId);
  Future<Either<Failure, List<UserModel>>> getFollowingList(int userId);

  // --- CİHAZ VE BİLDİRİM ---
  /// FCM Token ve cihaz bilgilerini backend'e senkronize eder.
  Future<Either<Failure, void>> registerDevice(Map<String, dynamic> data);
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> getMe() async {
    return await _handleException(() => remoteDataSource.getMe());
  }

  @override
  Future<Either<Failure, UserModel>> updateMe(Map<String, dynamic> data) async {
    return await _handleException(() => remoteDataSource.updateMe(data));
  }

  @override
  Future<Either<Failure, void>> deactivateMe() async {
    return await _handleException(() => remoteDataSource.deactivateMe());
  }

  @override
  Future<Either<Failure, UserModel>> uploadProfileImage(String filePath) async {
    return await _handleException(
      () => remoteDataSource.uploadProfileImage(filePath),
    );
  }

  @override
  Future<Either<Failure, UserModel>> getUserById(int userId) async {
    return await _handleException(() => remoteDataSource.getUserById(userId));
  }

  @override
  Future<Either<Failure, List<UserModel>>> searchUsers(String query) async {
    return await _handleException(() => remoteDataSource.searchUsers(query));
  }

  // --- CİHAZ VE BİLDİRİM ---

  @override
  Future<Either<Failure, void>> registerDevice(
    Map<String, dynamic> data,
  ) async {
    return await _handleException(() => remoteDataSource.registerDevice(data));
  }

  // --- TAKİP SİSTEMİ ---

  @override
  Future<Either<Failure, void>> followStreamer(int streamerId) async {
    return await _handleException(
      () => remoteDataSource.followStreamer(streamerId),
    );
  }

  @override
  Future<Either<Failure, void>> unfollowStreamer(int streamerId) async {
    return await _handleException(
      () => remoteDataSource.unfollowStreamer(streamerId),
    );
  }

  @override
  Future<Either<Failure, List<UserModel>>> getFollowerList(
    int streamerId,
  ) async {
    return await _handleException(
      () => remoteDataSource.getFollowerList(streamerId),
    );
  }

  @override
  Future<Either<Failure, List<UserModel>>> getFollowingList(int userId) async {
    return await _handleException(
      () => remoteDataSource.getFollowingList(userId),
    );
  }

  // Kod tekrarını önlemek için yardımcı metod
  Future<Either<Failure, T>> _handleException<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'İşlem başarısız oldu';
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
