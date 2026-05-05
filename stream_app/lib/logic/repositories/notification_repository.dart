import 'package:dartz/dartz.dart';
import '../../core/failures.dart';
import '../../data/models/notification/notification_model.dart';
import '../../data/datasources/notification_remote_datasource.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications({int limit = 20, int offset = 0});
  Future<Either<Failure, void>> markAsRead(int id);
  Future<Either<Failure, void>> markAllAsRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({int limit = 20, int offset = 0}) async {
    try {
      final result = await remoteDataSource.getNotifications(limit: limit, offset: offset);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
