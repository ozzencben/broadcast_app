import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/views/screens/tabs/profile/admin_profile_screen.dart';
import 'package:stream_app/views/screens/tabs/profile/profile_screen.dart';
import 'package:stream_app/views/screens/tabs/profile/streamer_profile_screen.dart';

class ProfileWrapper extends StatelessWidget {
  const ProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user.isAdmin) {
          return const AdminProfileScreen();
        }

        if (user.isStreamer) {
          return const StreamerProfileScreen();
        }

        return const ProfileScreen();
      },
    );
  }
}
