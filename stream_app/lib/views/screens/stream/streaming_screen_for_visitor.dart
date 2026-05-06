import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:livekit_client/livekit_client.dart';

class StreamingScreenForVisitor extends StatefulWidget {
  final String roomName;

  const StreamingScreenForVisitor({super.key, required this.roomName});

  @override
  State<StreamingScreenForVisitor> createState() =>
      _StreamingScreenForVisitorState();
}

class _StreamingScreenForVisitorState extends State<StreamingScreenForVisitor> {
  // LiveKit dinleyicisi için değişken
  EventsListener<RoomEvent>? _listener;

  @override
  void initState() {
    super.initState();
    // LiveKit dinleyicisini frame çizildikten sonra güvenle başlatıyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final room = context.read<LiveStreamProvider>().room;
      if (room != null) {
        _setupRoomListeners(room);
      }
    });
  }

  @override
  void dispose() {
    // Hafıza sızıntısını önlemek için dinleyiciyi kapatıyoruz
    _listener?.dispose();
    super.dispose();
  }

  /* --- LİVEKİT DİNLEYİCİSİ --- */
  void _setupRoomListeners(Room room) {
    _listener = room.createListener();

    // Yayıncının kamerası bize ulaştığında ekranı yenile
    _listener!.on<TrackSubscribedEvent>((event) {
      if (mounted) setState(() {});
    });

    // Yayıncı kamerasını kapatırsa veya track düşerse ekranı yenile
    _listener!.on<TrackUnsubscribedEvent>((event) {
      if (mounted) setState(() {});
    });

    // Oda teknik bir hatadan veya yayıncının kapatmasından dolayı düşerse atılmayı bekle
    _listener!.on<RoomDisconnectedEvent>((event) {
      if (mounted) {
        debugPrint("LiveKit: Oda kapandı. İzleyici atılıyor.");
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    });
  }

  void _leaveStream(BuildContext context) async {
    // İzleyici kendi isteğiyle çıkarsa
    final provider = context.read<LiveStreamProvider>();
    final navigator = Navigator.of(context);
    
    // Önce odadan ayrılalım
    await provider.leaveCurrentRoom();
    
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamProvider = context.watch<LiveStreamProvider>();
    final currentConnection = streamProvider.currentConnection;
    final currentStream = currentConnection?.stream;

    // Yayın verisi koptuysa siyah ekran göster ki arkada hata patlamasın (Wrapper zaten atacak)
    if (currentStream == null) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    // YAYINCININ (REMOTE PARTICIPANT) KANALLARINI BUL
    final room = streamProvider.room;
    final remoteParticipant = room?.remoteParticipants.values.firstOrNull;
    final remoteVideoTrack =
        remoteParticipant?.videoTrackPublications.firstOrNull?.track;

    return Scaffold(
      backgroundColor: Colors.black, // Arka plan tamamen siyah
      resizeToAvoidBottomInset: false, // Klavyenin ekranı itmesini önle
      body: SizedBox.expand(
        // Ekranı tamamen kaplamasını sağla
        child: Stack(
          fit: StackFit.expand, // İçerikleri ekran sınırlarına zorla
          children: [
            // ==========================================
            // 1. GERÇEK VİDEO ALANI (Tam Ortalı)
            // ==========================================
            if (remoteVideoTrack != null)
              Center(
                child: VideoTrackRenderer(
                  remoteVideoTrack as VideoTrack,
                  fit: VideoViewFit.cover,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (streamProvider.errorMessage != null) ...[
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          streamProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Geri Dön"),
                      ),
                    ] else ...[
                      Icon(
                        Icons.cell_tower,
                        color: AppTheme.accentPurple.withValues(alpha: 0.5),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Yayıncı Bekleniyor...",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),

            // ==========================================
            // 2. ÜST GÖLGELENDİRME (Gradient)
            // ==========================================
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // 3. ALT GÖLGELENDİRME (Gradient)
            // ==========================================
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // 4. TOP OVERLAY (Stream Info)
            // ==========================================
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CANLI Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          "CANLI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // İzleyici Sayısı
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${currentStream.viewerCount ?? 0}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Odadan Çıkış Butonu
                      IconButton(
                        onPressed: () => _leaveStream(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // 5. BOTTOM OVERLAY (Viewer Controls)
            // ==========================================
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 40.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1,
                            ), // Şık bir kenarlık
                          ),
                          child: const Text(
                            "Sohbete katıl...",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentPurple.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
