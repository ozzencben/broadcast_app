import 'package:permission_handler/permission_handler.dart';

/// 1. Uygulama İçi İzin Tiplerimiz (Genişletilebilir Kısım)
/// İleride buraya 'location', 'storage' vb. ekleyebilirsin.
enum AppPermission {
  camera,
  microphone,
  notification,
}

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
    }
  }
}

/// 2. Servis Arayüzü
abstract class PermissionService {
  /// Tek bir iznin durumunu kontrol eder (Sormaz, sadece bakar)
  Future<bool> hasPermission(AppPermission permission);
  
  /// Tek bir izin ister
  Future<bool> requestPermission(AppPermission permission);
  
  /// Aynı anda birden fazla izin ister (Yayın için kamera+mikrofon gibi)
  /// Geriye hangi iznin verilip verilmediğini map olarak döner
  Future<Map<AppPermission, bool>> requestMultiple(List<AppPermission> permissions);
  
  /// Kullanıcı izni kalıcı olarak reddettiyse onu ayarlara yönlendirir
  Future<bool> openSettings();
}

/// 3. Servis Uygulaması
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
  Future<Map<AppPermission, bool>> requestMultiple(List<AppPermission> permissions) async {
    final targetPermissions = permissions.map((p) => p.toPermission).toList();
    
    // Paket aynı anda birden fazla izin istemeyi destekler
    final statuses = await targetPermissions.request();
    
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