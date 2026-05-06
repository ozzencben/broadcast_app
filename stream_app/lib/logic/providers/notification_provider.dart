import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/models/notification/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  NotificationProvider({required NotificationRepository repository})
    : _repository = repository;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  int _offset = 0;
  final int _limit = 20;

  // --- WEBSOCKET DEĞİŞKENLERİ ---
  WebSocketChannel? _channel;
  bool _isConnected = false;
  // Kendi backend IP/URL'ini buraya yaz
  final String _wsBaseUrl =
      "ws://192.168.1.107:8000/api/websocket/notifications";

  Future<void> fetchHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      _offset = 0;
      _hasMoreData = true;
      _notifications = [];
    }

    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    final result = await _repository.getNotifications(
      limit: _limit,
      offset: _offset,
    );

    result.fold((failure) => debugPrint(failure.message), (newNotifications) {
      if (newNotifications.length < _limit) _hasMoreData = false;
      _notifications.addAll(newNotifications);
      _offset += newNotifications.length;
      _calculateUnreadCount();
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // Local optimistik güncelleme
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _calculateUnreadCount();
      notifyListeners();

      // Backend güncelleme
      await _repository.markAsRead(id);
    }
  }

  Future<void> markAllAsRead() async {
    // Local optimistik güncelleme
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _unreadCount = 0;
    notifyListeners();

    // Backend güncelleme
    await _repository.markAllAsRead();
  }

  /// WEBSOCKET BAĞLANTISINI BAŞLAT
  void connectWebSocket(int userId) {
    if (_isConnected) return;

    final wsUrl = Uri.parse("$_wsBaseUrl/$userId");
    _channel = WebSocketChannel.connect(wsUrl);
    _isConnected = true;

    debugPrint("🔔 WebSocket Bildirim Kanalına Bağlanıldı (User: $userId)");

    _channel!.stream.listen(
      (message) {
        _handleLiveNotification(message);
      },
      onError: (error) {
        debugPrint("❌ WebSocket Bildirim Hatası: $error");
        _isConnected = false;
        _reconnectWebSocket(userId);
      },
      onDone: () {
        debugPrint("🛑 WebSocket Bildirim Kanalı Kapandı.");
        _isConnected = false;
      },
    );
  }

  /// WEBSOCKET'TEN GELEN ANLIK MESAJI İŞLE VE LİSTEYE EKLE
  void _handleLiveNotification(dynamic message) {
    try {
      final decodedData = jsonDecode(message);

      if (decodedData['type'] == 'NEW_NOTIFICATION') {
        final data = decodedData['data'];

        // Backend'den eklediğimiz GERÇEK ID'yi alıyoruz (Sahte ID tuzağını çözdük)
        final realId = data['id'] != null
            ? int.tryParse(data['id'].toString()) ?? 0
            : 0;

        final newNotif = NotificationModel(
          id: realId,
          userId: data['user_id'] ?? 0,
          type: data['event_type'] ?? 'unknown', // Backend'deki modele göre
          title: data['title'] ?? 'Yeni Bildirim',
          body: data['message'] ?? '',
          imageUrl:
              data['metadata']?['follower_avatar'] ?? '', // Metadata içindeyse
          data: data['metadata'] ?? {},
          isRead: false,
          createdAt: DateTime.now(),
        );

        // Listeye en baştan ekle
        _notifications.insert(0, newNotif);
        _calculateUnreadCount();
        notifyListeners();

        debugPrint("🚀 Canlı Bildirim Eklendi: ${newNotif.title}");
      }
    } catch (e) {
      debugPrint("Live Notification Parse Hatası: $e");
    }
  }

  void _reconnectWebSocket(int userId) {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) connectWebSocket(userId);
    });
  }

  void disconnectWebSocket() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }

  void addLiveNotification(Map<String, dynamic> data) {
    // FCM data map'i String döner, bu yüzden ID'yi parse etmeliyiz
    final realId = data['id'] != null
        ? int.tryParse(data['id'].toString()) ?? 0
        : 0;

    final newNotif = NotificationModel(
      id: realId, // Backend'den gelen GERÇEK ID
      userId: 0,
      type: data['type'] ?? 'unknown',
      title: data['title'] ?? 'Yeni Bildirim',
      body: data['message'] ?? '', // Backend'de 'message' olarak yolladık
      imageUrl: data['image_url'] ?? '', // Backend'e göre uyarlandı
      data: data,
      isRead: false,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, newNotif);
    _calculateUnreadCount();
    notifyListeners();
  }
}
