import 'package:flutter/material.dart';
import 'package:stream_app/data/models/user/user_model.dart';

class OtherAdminProfileScreen extends StatelessWidget {
  final UserModel user;
  const OtherAdminProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: const Center(child: Text('Other Admin Profile Content')),
    );
  }
}
