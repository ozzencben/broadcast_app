import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:stream_app/views/screens/stream/streaming_screen.dart';
import 'package:stream_app/views/screens/stream/streaming_screen_for_visitor.dart';
import '../../logic/providers/user_provider.dart';


class StreamWrapper extends StatelessWidget {
  final String roomName; // Odayı her zaman dışarıdan alıyoruz

  const StreamWrapper({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    // Auth yerine kendi projendeki UserProvider'ı kullanıyoruz (Profil ekranında öyle yapmıştın)
    final userProvider = context.watch<UserProvider>();
    final streamProvider = context.watch<LiveStreamProvider>();

    final user = userProvider.user;
    final currentStream = streamProvider.currentConnection?.stream;

    // 1. Kullanıcı veya Yayın verisi henüz gelmediyse yükleniyor göster
    if (user == null || currentStream == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // 2. KRİTİK KONTROL: Bu yayının sahibi ben miyim?
    // Kullanıcı ID'si ile yayını başlatanın ID'si aynıysa, yayıncı benim demektir.
    final isMyStream = currentStream.streamerId == user.id;

    if (isMyStream) {
      // Yayıncı ekranına git
      return StreamingScreen(roomName: roomName);
    } else {
      // İzleyici ekranına git
      return StreamingScreenForVisitor(roomName: roomName);
    }
  }
}