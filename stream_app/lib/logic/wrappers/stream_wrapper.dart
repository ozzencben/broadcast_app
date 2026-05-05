import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:stream_app/views/screens/stream/streaming_screen.dart';
import 'package:stream_app/views/screens/stream/streaming_screen_for_visitor.dart';
import '../../logic/providers/user_provider.dart';

class StreamWrapper extends StatelessWidget {
  final String roomName;

  const StreamWrapper({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final streamProvider = context.watch<LiveStreamProvider>();

    final user = userProvider.user;
    final currentStream = streamProvider.currentConnection?.stream;

    // 1. Kullanıcı verisi henüz yüklenmediyse bekle
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // 2. WEBSOCKET MÜDAHALESİ: Eğer yayın verisi null olduysa (Yayın bittiyse)
    if (currentStream == null) {
      // Çizim işlemi biter bitmez kullanıcıyı önceki sayfaya (Explore) geri şutluyoruz.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          // İstersen burada bir SnackBar da gösterebiliriz
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yayıncı yayını sonlandırdı.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pop(context);
        }
      });

      // Çıkış yapılana kadar siyah bir ekran göster (Hata almamak için)
      return const Scaffold(backgroundColor: Colors.black);
    }

    // 3. KRİTİK KONTROL: Bu yayının sahibi ben miyim?
    final isMyStream = currentStream.streamerId == user.id;

    if (isMyStream) {
      return StreamingScreen(roomName: roomName);
    } else {
      return StreamingScreenForVisitor(roomName: roomName);
    }
  }
}
