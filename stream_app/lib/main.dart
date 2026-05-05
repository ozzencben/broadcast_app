import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/locator.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/services/notification_service.dart';
import 'package:stream_app/logic/providers/admin_provider.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/providers/notification_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:stream_app/logic/wrappers/auth_wrapper.dart';

import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase Başlatma (CRITICAL)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupLocator();

  // Auto login denemesi
  locator<AuthProvider>().tryAutoLogin();

  // Notification Service dinleyicisini başlat (Locator üzerinden)
  locator<NotificationService>().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locator<AuthProvider>()),
        ChangeNotifierProvider.value(value: locator<UserProvider>()),
        ChangeNotifierProvider.value(value: locator<AdminProvider>()),
        ChangeNotifierProvider.value(value: locator<NotificationProvider>()),
        ChangeNotifierProvider.value(value: locator<LiveStreamProvider>()),
      ],
      child: const StreamApp(),
    ),
  );
}

class StreamApp extends StatelessWidget {
  const StreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}
