import 'package:flutter/material.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/views/screens/profile/other_admin_profile_screen.dart';
import 'package:stream_app/views/screens/profile/other_streamer_profile_screen.dart';
import 'package:stream_app/views/screens/profile/other_user_profile_screen.dart';



class OtherProfileWrapper extends StatelessWidget {
  final UserModel user;

  const OtherProfileWrapper({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Admin Kontrolü
    if (user.isAdmin) {
      return OtherAdminProfileScreen(user: user); 
      // Not: Bu ekranların içine constructor ile 'user' verisini göndermelisin.
    }

    // 2. Streamer Kontrolü
    if (user.isStreamer) {
      return OtherStreamerProfileScreen(user: user);
    }

    // 3. Standart Kullanıcı
    return OtherUserProfileScreen(user: user);
  }
}