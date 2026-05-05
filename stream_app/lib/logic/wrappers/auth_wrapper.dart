import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/wrappers/main_wrapper.dart';
import 'package:stream_app/views/screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // 1. Uygulama açılırken tryAutoLogin() sonucunu bekliyoruz
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        }

        // 2. Kullanıcı varsa ana sayfaya, yoksa giriş ekranına
        if (authProvider.currentUser != null) {
          return const MainWrapper();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
