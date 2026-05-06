import 'package:permission_handler/permission_handler.dart';

/// 1. Uygulama İçi İzin Tiplerimiz
/// LiveKit için özellikle camera, microphone ve bluetooth (kulaklıklar için) kritiktir.
enum AppPermission { camera, microphone, notification, bluetooth }

/// Enum'ı permission_handler'ın anladığı tipe çeviren extension
extension AppPermissionExtension on AppPermission {
  Permission get toPermission {
    switch (this) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.microphone:
        return Permission.microphone;
      case AppPermission.notification:
        return Permission.notification;
      case AppPermission.bluetooth:
        // Android 12+ için BluetoothConnect, alt sürümler için standart bluetooth
        return Permission.bluetoothConnect;
    }
  }
}

/// 2. Servis Arayüzü (Interface)
abstract class PermissionService {
  /// Tek bir iznin durumunu kontrol eder (Sormaz, sadece mevcut duruma bakar)
  Future<bool> hasPermission(AppPermission permission);

  /// Tek bir izin ister
  Future<bool> requestPermission(AppPermission permission);

  /// Aynı anda birden fazla izin ister (Yayın için kamera+mikrofon gibi)
  /// Geriye hangi iznin verilip verilmediğini Map olarak döner
  Future<Map<AppPermission, bool>> requestMultiple(
    List<AppPermission> permissions,
  );

  /// Kullanıcı izni kalıcı olarak reddettiyse onu cihaz ayarlarına yönlendirir
  Future<bool> openSettings();
}

/// 3. Servis Uygulaması (Implementation)
class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> hasPermission(AppPermission permission) async {
    final status = await permission.toPermission.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission(AppPermission permission) async {
    final status = await permission.toPermission.request();
    return status.isGranted;
  }

  @override
  Future<Map<AppPermission, bool>> requestMultiple(
    List<AppPermission> permissions,
  ) async {
    // Enum listesini permission_handler'ın beklediği Permission listesine çevir
    final targetPermissions = permissions.map((p) => p.toPermission).toList();

    // Paket üzerinden toplu izin isteği at
    final Map<Permission, PermissionStatus> statuses = await targetPermissions
        .request();

    // Sonuçları tekrar kendi enum tipimize map'leyerek geri döndür
    final result = <AppPermission, bool>{};
    for (var p in permissions) {
      result[p] = statuses[p.toPermission]?.isGranted ?? false;
    }

    return result;
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
