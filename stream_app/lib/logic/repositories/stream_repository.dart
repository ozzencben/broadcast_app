import 'package:dartz/dartz.dart';
import 'package:stream_app/data/models/stream/stream_model.dart';
import '../../core/failures.dart';
import '../../data/datasources/stream_remote_datasource.dart';

abstract class StreamRepository {
  Future<Either<Failure, List<StreamModel>>> getActiveStreams({int skip = 0, int limit = 10});
  Future<Either<Failure, StreamConnectionResponse>> startStream(String title);
  Future<Either<Failure, StreamConnectionResponse>> joinStream(String roomName);
  Future<Either<Failure, void>> endStream(String roomName);
}

class StreamRepositoryImpl implements StreamRepository {
  final StreamRemoteDataSource remoteDataSource;
  StreamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StreamModel>>> getActiveStreams({int skip = 0, int limit = 10}) async {
    try {
      final result = await remoteDataSource.getActiveStreams(skip: skip, limit: limit);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StreamConnectionResponse>> startStream(String title) async {
    try {
      final result = await remoteDataSource.startStream(title);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StreamConnectionResponse>> joinStream(String roomName) async {
    try {
      final result = await remoteDataSource.joinStream(roomName);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endStream(String roomName) async {
    try {
      await remoteDataSource.endStream(roomName);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}