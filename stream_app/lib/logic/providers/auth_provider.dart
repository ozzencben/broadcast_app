import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stream_app/core/locator.dart';
import 'package:stream_app/data/services/device_info_service.dart';
import 'package:stream_app/logic/providers/notification_provider.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:stream_app/logic/repositories/auth_repository_impl.dart';
import 'package:stream_app/logic/repositories/user_repository_impl.dart';
import '../../data/models/auth/auth_request_model.dart';
import '../../data/models/user/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final UserRepository _userRepository;
  final FlutterSecureStorage _secureStorage;
  final DeviceInfoService _deviceInfoService;

  AuthProvider({
    required AuthRepository repository,
    required UserRepository userRepository,
    required FlutterSecureStorage secureStorage,
    required DeviceInfoService deviceInfoService,
  }) : _repository = repository,
       _userRepository = userRepository,
       _secureStorage = secureStorage,
       _deviceInfoService = deviceInfoService;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Cihaz bilgilerini backend ile senkronize eder.
  /// Bildirim sistemi için kritik el sıkışma (handshake) noktasıdır.
  Future<void> _syncDeviceToken() async {
    try {
      final payload = await _deviceInfoService.getDevicePayload();
      final result = await _userRepository.registerDevice(payload);

      result.fold(
        (failure) => debugPrint("Device Sync Error: ${failure.message}"),
        (_) => debugPrint("Device Sync Success: Token registered."),
      );
    } catch (e) {
      debugPrint("Device Sync Exception: $e");
    }
  }

  Future<void> tryAutoLogin() async {
    _setLoading(true);

    try {
      final token = await _secureStorage.read(key: 'access_token');

      if (token == null) {
        _currentUser = null;
        return;
      }

      final result = await _userRepository.getMe();

      await result.fold(
        (failure) async {
          _errorMessage = failure.message;
          _currentUser = null;
          await _secureStorage.deleteAll();
        },
        (user) async {
          _currentUser = user;
          // Oturum geçerliyse cihazı arka planda senkronize et
          await _syncDeviceToken();

          try {
            final notifProvider = locator<NotificationProvider>();
            await notifProvider.fetchHistory(isRefresh: true); // Geçmişi çek
            notifProvider.connectWebSocket(user.id); // Canlı hattı aç
          } catch (e) {
            debugPrint("AutoLogin Notification Init Hatası: $e");
          }
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final request = AuthRequestModel(email: email, password: password);
    final result = await _repository.login(request);

    return await result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (successResponse) async {
        _currentUser = successResponse.user;
        await _syncDeviceToken();

        try {
          final notifProvider = locator<NotificationProvider>();
          await notifProvider.fetchHistory(isRefresh: true);
          notifProvider.connectWebSocket(successResponse.user.id);
        } catch (e) {
          debugPrint("Login Notification Init Hatası: $e");
        }

        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    final request = AuthRequestModel(email: email, password: password);
    final result = await _repository.register(request);

    return await result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (successResponse) async {
        _currentUser = successResponse.user;
        await _syncDeviceToken();

        try {
          final notifProvider = locator<NotificationProvider>();
          await notifProvider.fetchHistory(isRefresh: true);
          notifProvider.connectWebSocket(successResponse.user.id);
        } catch (e) {
          debugPrint("Register Notification Init Hatası: $e");
        }

        _setLoading(false);
        return true;
      },
    );
  }

  void logout() async {
    _currentUser = null;
    await _secureStorage.deleteAll();

    try {
      locator<LiveStreamProvider>().disconnectWebSocket();

      locator<NotificationProvider>().disconnectWebSocket();
    } catch (e) {
      debugPrint("Logout sırasında WebSocket kapatılamadı: $e");
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
