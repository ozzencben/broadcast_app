import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; 
import 'package:stream_app/core/locator.dart';
import 'package:stream_app/data/services/device_info_service.dart';
import 'package:stream_app/logic/repositories/user_repository_impl.dart';

class NotificationService {
  final UserRepository _userRepository;
  final DeviceInfoService _deviceInfoService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService({
    required UserRepository userRepository,
    required DeviceInfoService deviceInfoService,
  }) : _userRepository = userRepository,
       _deviceInfoService = deviceInfoService;

  Future<void> initialize() async {
    // 1. Firebase OS İzinleri
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // 2. Local Notifications Başlatma
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _handleNotificationClick,
    );

    // 3. Android High Importance Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'System and follow alerts.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 4. Foreground Message Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground Message Received: ${message.messageId}");

      // DİKKAT: Artık provider.addFCMNotification ÇAĞIRMIYORUZ!
      // Çünkü listeye ekleme işini anlık olarak WebSocket yapacak.
      
      // Sadece ekranın üstünden süzülen yerel bildirimi (pop-up) gösteriyoruz
      _showLocalNotification(message, channel);
    });

    // 5. Background / Terminated Click Listener
    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationClickFromFCM,
    );

    // 6. Token Refresh Listener
    _messaging.onTokenRefresh.listen(_syncNewToken);
  }

  void _handleNotificationClick(NotificationResponse response) {
    debugPrint("Local Notification Clicked: ${response.payload}");
    _dispatchNavigation(response.payload);
  }

  void _handleNotificationClickFromFCM(RemoteMessage message) {
    debugPrint("FCM Notification Opened App: ${message.data}");
    _dispatchNavigation(message.data.toString());
  }

  // Decoupled Navigation Dispatcher
  void _dispatchNavigation(String? payload) {
    if (payload == null) return;
    // locator içinde tanımlanmış global bir GlobalKey<NavigatorState> olduğunu varsayıyoruz.
    // Bu sayede UI context'ine ihtiyaç duymadan yönlendirme yapılabilir.
    try {
      final navigatorKey = locator<GlobalKey<NavigatorState>>();
      navigatorKey.currentState?.pushNamed('/notifications');
    } catch (e) {
      debugPrint("Navigation dispatch failed: $e");
    }
  }

  Future<void> _showLocalNotification(
    RemoteMessage message,
    AndroidNotificationChannel channel,
  ) async {
    final notification = message.notification;
    if (notification == null) return;

    // DÜZELTİLDİ: Tüm argümanlar açık isimleriyle (named parameters) belirtildi.
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  Future<void> _syncNewToken(String token) async {
    final payload = await _deviceInfoService.getDevicePayload();
    payload['fcm_token'] = token;
    await _userRepository.registerDevice(payload);
  }
}
