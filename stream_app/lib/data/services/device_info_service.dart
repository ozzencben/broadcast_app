import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<Map<String, String>> getDevicePayload() async {
    // 1. FCM Token'ı al
    String? token = await _firebaseMessaging.getToken();

    // 2. Cihaz modelini al
    String model = "Unknown Device";
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      model = "${androidInfo.manufacturer} ${androidInfo.model}";
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      model = iosInfo.utsname.machine;
    }

    return {
      "fcm_token": token ?? "",
      "device_type": Platform.isAndroid ? "android" : "ios",
      "device_model": model,
    };
  }
}