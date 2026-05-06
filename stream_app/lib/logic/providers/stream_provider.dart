import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart'; // LİVEKİT IMPORTU
import 'package:stream_app/core/locator.dart';
import 'package:stream_app/data/models/stream/stream_model.dart';
import 'package:stream_app/data/services/permisson_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../repositories/stream_repository.dart';

class LiveStreamProvider extends ChangeNotifier {
  final StreamRepository _repository;
  LiveStreamProvider({required StreamRepository repository})
    : _repository = repository;

  // --- 1. HABERLEŞME HATTI (FastAPI WebSocket) ---
  final String _wsDiscoveryUrl =
      'ws://192.168.1.107:8000/api/websocket/streams';
  WebSocketChannel? _channel;

  // --- 2. GÖRÜNTÜ HATTI (LiveKit Server) ---
  final String _livekitUrl = 'ws://192.168.1.107:7880';
  Room? _room;
  Room? get room => _room;

  // Aktif yayınların listesi
  List<StreamModel> _activeStreams = [];
  List<StreamModel> get activeStreams => _activeStreams;

  // Şu an içinde bulunduğumuz veya başlattığımız yayının bağlantı detayı (Token vb.)
  StreamConnectionResponse? _currentConnection;
  StreamConnectionResponse? get currentConnection => _currentConnection;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  int _skip = 0;
  final int _limit = 10;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // =========================================================================
  // 1. WEBSOCKET (SİNYALİZASYON) YÖNETİMİ
  // =========================================================================

  /// WebSocket bağlantısını başlatır ve dinlemeye geçer
  void connectWebSocket() {
    if (_channel != null) return;

    try {
      final wsUrl = Uri.parse(_wsDiscoveryUrl);
      _channel = WebSocketChannel.connect(wsUrl);

      debugPrint("🔌 WebSocket bağlantısı kuruluyor...");

      _channel!.stream.listen(
        (message) {
          debugPrint("📡 [WebSocket Mesajı]: $message");
          final data = jsonDecode(message);

          if (data['type'] == 'NEW_STREAM_STARTED') {
            debugPrint("🟢 Yeni yayın tespit edildi, liste yenileniyor!");
            fetchActiveStreams(isRefresh: true);
          } else if (data['type'] == 'STREAM_ENDED') {
            final roomName = data['room_name'];
            debugPrint("🔴 Yayın bitti: $roomName. Listeden çıkarılıyor.");
            _activeStreams.removeWhere((s) => s.roomName == roomName);
            notifyListeners();

            if (_currentConnection?.stream.roomName == roomName) {
              _errorMessage = "This stream has ended by the host.";
              _currentConnection = null;
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint("❌ WebSocket Hatası: $error");
          _channel = null;
        },
        onDone: () {
          debugPrint("🛑 WebSocket Bağlantısı Koptu.");
          _channel = null;
        },
      );
    } catch (e) {
      debugPrint("WebSocket Kurulum Hatası: $e");
    }
  }

  void disconnectWebSocket() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      debugPrint("🛑 WebSocket manuel olarak kapatıldı.");
    }
  }

  // =========================================================================
  // 2. LİVEKİT (GÖRÜNTÜ VE SES) YÖNETİMİ
  // =========================================================================

  /// LiveKit odasına bağlanma işlemini yapan özel yardımcı metod
  Future<bool> _connectToLiveKitRoom(String token) async {
    try {
      if (_room != null) {
        await _room!.disconnect();
      }

      _room = Room();

      // Bağlantı denemesine timeout ve zayıf ağ (Low-End) optimizasyonları ekliyoruz
      await _room!
          .connect(
            _livekitUrl,
            token,
            roomOptions: const RoomOptions(
              // Simulcast'i KAPATTIK (Zayıf ağlarda Simulcast cihazı boğar)
              defaultVideoPublishOptions: VideoPublishOptions(simulcast: false),
              // Cihazın kendi internetine göre video almasını sağlayan Dynacast'i açtık
              dynacast: true,
            ),
            connectOptions: const ConnectOptions(
              // Wi-Fi kopmalarına karşı WebRTC'nin hemen pes etmesini engelle
              autoSubscribe: true,
            ),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("✅ LiveKit Odasına Bağlanıldı!");
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("❌ LiveKit Bağlantı Hatası: $e");
      _errorMessage = "Görüntü sunucusuna bağlanılamadı. (Hata: $e)";
      notifyListeners();
      return false;
    }
  }

  /// Mevcut LiveKit odasından çıkma metodu (İzleyici çıkar veya yayıncı yayını bitirirse)
  Future<void> leaveCurrentRoom() async {
    if (_room != null) {
      try {
        // Disconnect bazen timeout'a düşebiliyor, bunu yakalayıp devam etmeliyiz
        await _room!.disconnect().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint("⚠️ LiveKit Odasından ayrılırken hata/timeout: $e");
      } finally {
        _room = null;
        debugPrint("🛑 LiveKit Odasından Çıkıldı.");
      }
    }
    _currentConnection = null;
    notifyListeners();
  }

  // =========================================================================
  // 3. API VE İŞ MANTIĞI KATI (BUSINESS LOGIC)
  // =========================================================================

  /// Aktif yayınları sayfalama (pagination) ile çeker
  Future<void> fetchActiveStreams({bool isRefresh = false}) async {
    if (isRefresh) {
      _skip = 0;
      _hasMoreData = true;
      _activeStreams = [];
      notifyListeners();
    }

    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    final result = await _repository.getActiveStreams(
      skip: _skip,
      limit: _limit,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint("Stream Fetch Error: ${failure.message}");
      },
      (newStreams) {
        debugPrint(
          "LiveStreamProvider: Fetched ${newStreams.length} active streams.",
        );
        if (newStreams.length < _limit) _hasMoreData = false;

        for (var newStream in newStreams) {
          bool exists = _activeStreams.any((s) => s.id == newStream.id);
          if (!exists) {
            _activeStreams.add(newStream);
          }
        }
        _errorMessage = null;
        _skip += newStreams.length;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Yeni bir yayın başlatır ve token'ı hafızaya alır
  Future<bool> startStream(String title) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.startStream(title);
    bool success = false;

    // Fold içindeki callback asenkron olduğu için await ekliyoruz
    await result.fold(
      (failure) async {
        debugPrint("Start Stream Error: ${failure.message}");
        _errorMessage = failure.message;
      },
      (connectionResponse) async {
        _currentConnection = connectionResponse;
        _activeStreams.insert(0, connectionResponse.stream);

        // Backend'den token geldi, LiveKit'e bağlan!
        success = await _connectToLiveKitRoom(connectionResponse.token);
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Var olan bir yayına izleyici olarak katılır ve token'ı hafızaya alır
  Future<bool> joinStream(String roomName) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.joinStream(roomName);
    bool success = false;

    await result.fold(
      (failure) async {
        debugPrint("Join Stream Error: ${failure.message}");
        _errorMessage = failure.message;
      },
      (connectionResponse) async {
        _currentConnection = connectionResponse;

        // İzleyici olarak LiveKit odasına bağlan!
        success = await _connectToLiveKitRoom(connectionResponse.token);
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// YAYINCI AKIŞI: İzinleri alır, yayını başlatır ve kamerayı açar
  Future<void> handleStartStreamFlow(String title) async {
    final permissionService = locator<PermissionService>();

    // 1. İzinleri al
    final statuses = await permissionService.requestMultiple([
      AppPermission.camera,
      AppPermission.microphone,
    ]);

    final allGranted = statuses.values.every((isGranted) => isGranted);

    if (allGranted) {
      debugPrint("✅ Tüm izinler tamam. Yayın başlatılıyor...");

      // 2. Backend ve LiveKit bağlantısını kur
      final success = await startStream(title);

      if (success && _room != null) {
        debugPrint("🚀 LiveKit odasına girildi, medya kanalları açılıyor...");

        // Mikrofonu aktif et
        await _room!.localParticipant?.setMicrophoneEnabled(true);

        // KAMERA AYARLARI: Eski cihazlarda (S9 vb) uyumluluk için h480 veya h360 daha güvenlidir.
        // Çözünürlüğü ve Bitrate'i en dibe çektik (Zayıf ağ senaryosu)
        await _room!.localParticipant?.setCameraEnabled(
          true,
          cameraCaptureOptions: const CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
            params: VideoParameters(
              dimensions: VideoDimensions(320, 240),
              encoding: VideoEncoding(
                maxBitrate:
                    150000, // Sadece 150 kbps! (Zayıf Wi-Fi bile kaldırır)
                maxFramerate: 15, // FPS'i düşürerek işlemciyi rahatlattık
              ),
            ),
          ),
        );
      }
    } else {
      debugPrint("❌ Kamera veya Mikrofon izni reddedildi.");
      _errorMessage =
          "Yayın başlatmak için kamera ve mikrofon izni gereklidir.";
      notifyListeners();
    }
  }

  /// Yayını sonlandırır
  Future<void> endStream(String roomName) async {
    _activeStreams.removeWhere((stream) => stream.roomName == roomName);

    if (_currentConnection?.stream.roomName == roomName) {
      await leaveCurrentRoom(); // Odadan çık ve veriyi temizle
    } else {
      notifyListeners();
    }

    final result = await _repository.endStream(roomName);
    result.fold(
      (failure) => debugPrint("End Stream Error: ${failure.message}"),
      (_) => debugPrint("Stream successfully ended on backend."),
    );
  }

  @override
  void dispose() {
    disconnectWebSocket();
    _room?.disconnect(); // Provider ölürse kamerayı serbest bırak
    super.dispose();
  }
}
