import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stream_app/core/locator.dart';
import 'package:stream_app/data/models/stream/stream_model.dart';
import 'package:stream_app/data/services/permisson_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../repositories/stream_repository.dart';

class LiveStreamProvider extends ChangeNotifier {
  final StreamRepository _repository;
  LiveStreamProvider({required StreamRepository repository})
    : _repository = repository;

  WebSocketChannel? _channel;

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

  /// WebSocket bağlantısını başlatır ve dinlemeye geçer
  void connectWebSocket() {
    // Eğer zaten bağlıysa tekrar bağlanma
    if (_channel != null) return;

    try {
      // Kendi lokal IP adresini buraya yaz (Örn: 192.168.1.107)
      // TODO: ileride burası constant olarak ayarlanmalı (url)
      final wsUrl = Uri.parse('ws://192.168.1.107:8000/api/websocket/streams');
      _channel = WebSocketChannel.connect(wsUrl);

      debugPrint("🔌 WebSocket bağlantısı kuruluyor...");

      _channel!.stream.listen(
        (message) {
          debugPrint("📡 [WebSocket Mesajı]: $message");
          final data = jsonDecode(message);

          if (data['type'] == 'NEW_STREAM_STARTED') {
            // Yeni yayın başladıysa listeyi baştan çek (En garantili yöntem)
            debugPrint("🟢 Yeni yayın tespit edildi, liste yenileniyor!");
            fetchActiveStreams(isRefresh: true);
          } else if (data['type'] == 'STREAM_ENDED') {
            // Yayın bittiyse sadece o yayını listeden silip UI'ı güncelle
            final roomName = data['room_name'];
            debugPrint("🔴 Yayın bitti: $roomName. Listeden çıkarılıyor.");
            _activeStreams.removeWhere((s) => s.roomName == roomName);
            notifyListeners();

            // 2. EĞER izleyici şu an bu yayının içindeyse bir sinyal gönder
            if (_currentConnection?.stream.roomName == roomName) {
              // İzleyiciyi dışarı atmak için bir hata mesajı set edebiliriz
              _errorMessage = "This stream has ended by the host.";
              _currentConnection = null; // Bağlantı verisini temizle
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
          // İleride buraya "otomatik yeniden bağlanma" (reconnect) mantığı eklenebilir
        },
      );
    } catch (e) {
      debugPrint("WebSocket Kurulum Hatası: $e");
    }
  }

  /// WebSocket bağlantısını manuel olarak kapatır
  void disconnectWebSocket() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      debugPrint("🛑 WebSocket manuel olarak kapatıldı.");
    }
  }

  /// Provider hafızadan silinirken sızıntı (memory leak) olmasın diye bağlantıyı kesiyoruz
  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }

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
          // Eğer id zaten listede varsa ekleme (Duplikasyon önleme)
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

    result.fold(
      (failure) => debugPrint("Start Stream Error: ${failure.message}"),
      (connectionResponse) {
        _currentConnection = connectionResponse;

        // Optimistik olarak başlattığımız yayını listeye en başa ekleyebiliriz
        _activeStreams.insert(0, connectionResponse.stream);
        success = true;
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

    result.fold(
      (failure) => debugPrint("Join Stream Error: ${failure.message}"),
      (connectionResponse) {
        _currentConnection = connectionResponse;
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> handleStartStreamFlow(String title) async {
    final permissionService = locator<PermissionService>();

    // 1. İzinleri Kontrol Et ve İste
    final statuses = await permissionService.requestMultiple([
      AppPermission.camera,
      AppPermission.microphone,
    ]);

    // 2. İzinlerin durumunu kontrol et
    final allGranted = statuses.values.every((isGranted) => isGranted);

    if (allGranted) {
      debugPrint("✅ Tüm izinler tamam. Yayın başlatılıyor...");

      // 3. Gerçek API çağrısını yap
      final success = await startStream(title);

      if (success) {
        debugPrint(
          "🚀 Yayın başarıyla açıldı! Token: ${currentConnection?.token}",
        );
      }
    } else {
      // 4. İzinlerden biri veya ikisi reddedildiyse kullanıcıyı uyar
      debugPrint("❌ Kamera veya Mikrofon izni reddedildi.");
      // Burada bir UI uyarısı fırlatabilirsin.
    }
  }

  /// Yayını sonlandırır
  Future<void> endStream(String roomName) async {
    // 1. Local (Optimistik) Güncelleme: Yayını hemen listeden uçur
    _activeStreams.removeWhere((stream) => stream.roomName == roomName);

    // Eğer bitirdiğimiz yayın şu an aktif olarak bulunduğumuz yayınsa veriyi temizle
    if (_currentConnection?.stream.roomName == roomName) {
      _currentConnection = null;
    }
    notifyListeners();

    // 2. Backend Güncellemesi
    final result = await _repository.endStream(roomName);
    result.fold(
      (failure) => debugPrint("End Stream Error: ${failure.message}"),
      (_) => debugPrint("Stream successfully ended."),
    );
  }
}
