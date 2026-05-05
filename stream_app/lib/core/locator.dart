import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:stream_app/data/datasources/admin_remote_datasource.dart';
import 'package:stream_app/data/datasources/auth_remote_datasource.dart';
import 'package:stream_app/data/datasources/notification_remote_datasource.dart';
import 'package:stream_app/data/datasources/stream_remote_datasource.dart';
import 'package:stream_app/data/datasources/user_remote_datasource.dart';
import 'package:stream_app/data/network/dio_client.dart';
import 'package:stream_app/data/services/device_info_service.dart';
import 'package:stream_app/data/services/notification_service.dart';
import 'package:stream_app/data/services/permisson_service.dart';
import 'package:stream_app/logic/providers/admin_provider.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/providers/notification_provider.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/logic/repositories/admin_repository_impl.dart';
import 'package:stream_app/logic/repositories/auth_repository_impl.dart';
import 'package:stream_app/logic/repositories/notification_repository.dart';
import 'package:stream_app/logic/repositories/stream_repository.dart';
import 'package:stream_app/logic/repositories/user_repository_impl.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // 1. Core Services
  locator.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // 2. Network
  locator.registerLazySingleton<Dio>(
    () => DioClient(locator<FlutterSecureStorage>()).dio,
  );

  // Services
  locator.registerLazySingleton<DeviceInfoService>(() => DeviceInfoService());
  locator.registerLazySingleton<NotificationService>(
    () => NotificationService(
      userRepository: locator<UserRepository>(),
      deviceInfoService: locator<DeviceInfoService>(),
    ),
  );
  locator.registerLazySingleton<PermissionService>(
    () => PermissionServiceImpl(),
  );

  // Data Sources
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: locator<Dio>()),
  );

  locator.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: locator<Dio>()),
  );

  locator.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(dio: locator<Dio>()),
  );

  locator.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dio: locator<Dio>()),
  );

  locator.registerLazySingleton<StreamRemoteDataSource>(
    () => StreamRemoteDataSourceImpl(dio: locator<Dio>()),
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: locator<AuthRemoteDataSource>(),
      secureStorage: locator<FlutterSecureStorage>(),
    ),
  );

  locator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: locator<UserRemoteDataSource>()),
  );

  locator.registerLazySingleton<AdminRepository>(
    () =>
        AdminRepositoryImpl(remoteDataSource: locator<AdminRemoteDataSource>()),
  );

  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: locator<NotificationRemoteDataSource>(),
    ),
  );

  locator.registerLazySingleton<StreamRepository>(
    () => StreamRepositoryImpl(
      remoteDataSource: locator<StreamRemoteDataSource>(),
    ),
  );

  // Providers (State Management)
  locator.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      userRepository: locator<UserRepository>(),
      secureStorage: locator<FlutterSecureStorage>(),
      repository: locator<AuthRepository>(),
      deviceInfoService: locator<DeviceInfoService>(),
    ),
  );

  locator.registerLazySingleton<UserProvider>(
    () => UserProvider(repository: locator<UserRepository>()),
  );

  locator.registerLazySingleton<AdminProvider>(
    () => AdminProvider(repository: locator<AdminRepository>()),
  );

  locator.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(repository: locator<NotificationRepository>()),
  );

  locator.registerLazySingleton<LiveStreamProvider>(
    () => LiveStreamProvider(repository: locator<StreamRepository>()),
  );
}
