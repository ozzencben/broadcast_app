import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/models/notification/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  NotificationProvider({required NotificationRepository repository}) : _repository = repository;

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

  Future<void> fetchHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      _offset = 0;
      _hasMoreData = true;
      _notifications = [];
    }

    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    final result = await _repository.getNotifications(limit: _limit, offset: _offset);

    result.fold(
      (failure) => debugPrint(failure.message),
      (newNotifications) {
        if (newNotifications.length < _limit) _hasMoreData = false;
        _notifications.addAll(newNotifications);
        _offset += newNotifications.length;
        _calculateUnreadCount();
      },
    );

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
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
    
    // Backend güncelleme
    await _repository.markAllAsRead();
  }

  /// FCM'den gelen anlık bildirimi listeye ekler (Inbox'ı canlı günceller)
  void addFCMNotification(RemoteMessage message) {
    final newNotif = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch, // Geçici unique ID
      userId: 0, 
      type: message.data['type'] ?? 'unknown',
      title: message.notification?.title ?? 'Yeni Bildirim',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl,
      data: message.data,
      isRead: false,
      createdAt: DateTime.now(),
    );
    
    _notifications.insert(0, newNotif);
    _unreadCount++;
    notifyListeners();
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }
}
