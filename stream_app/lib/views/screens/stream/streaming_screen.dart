import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StreamingScreen extends StatefulWidget {
  final String roomName;

  const StreamingScreen({super.key, required this.roomName});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  bool _isMicEnabled = true;
  bool _isCamEnabled = true;

  @override
  Widget build(BuildContext context) {
    final streamProvider = context.watch<LiveStreamProvider>();
    final currentStream = streamProvider.currentConnection?.stream;

    final room = streamProvider.room;
    final participant = room?.localParticipant;
    final localVideoTrack =
        participant?.videoTrackPublications.firstOrNull?.track;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // Klavye açılınca ekranı itmesin
      // 1. SIZEDBOX.EXPAND: Tüm ekranı zorla kaplamasını sağlıyoruz
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit
              .expand, // 2. STACK FIT: İçindekileri ekran boyutuna zorla
          children: [
            // ==========================================
            // VİDEO ALANI (En Alt Katman)
            // ==========================================
            if (localVideoTrack != null)
              VideoTrackRenderer(
                localVideoTrack as VideoTrack,
                fit: VideoViewFit.cover,
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
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Kamera Hazırlanıyor...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),

            // ==========================================
            // ÜST GÖLGELENDİRME
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
            // ALT GÖLGELENDİRME
            // ==========================================
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 250,
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
            // ÜST BİLGİ ÇUBUĞU (Top Overlay)
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
                              "${currentStream?.viewerCount ?? 0}",
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
                      IconButton(
                        onPressed: () => _showEndStreamDialog(context),
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
            // ALT KONTROLLER (Bottom Overlay)
            // ==========================================
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // 3. MIN SIZE: Sadece gerektiği kadar yer kapla
                    children: [
                      Text(
                        currentStream?.title ?? "Başlıksız Yayın",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                            onPressed: () async {
                              if (participant != null) {
                                final newState = !_isMicEnabled;
                                await participant.setMicrophoneEnabled(
                                  newState,
                                );
                                setState(() => _isMicEnabled = newState);
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildControlButton(
                            icon: _isCamEnabled
                                ? Icons.videocam
                                : Icons.videocam_off,
                            onPressed: () async {
                              if (participant != null) {
                                final newState = !_isCamEnabled;
                                await participant.setCameraEnabled(newState);
                                setState(() => _isCamEnabled = newState);
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildControlButton(
                            icon: Icons.cameraswitch,
                            onPressed: () async {
                              if (localVideoTrack is LocalVideoTrack) {
                                try {
                                  final cameras = await Helper.cameras;
                                  final trackSettings = localVideoTrack
                                      .mediaStreamTrack
                                      .getSettings();
                                  final currentDeviceId =
                                      trackSettings['deviceId'];

                                  final otherCamera = cameras.firstWhere(
                                    (c) => c.deviceId != currentDeviceId,
                                    orElse: () => cameras.first,
                                  );

                                  await localVideoTrack.switchCamera(
                                    otherCamera.deviceId,
                                  );
                                } catch (e) {
                                  debugPrint("Kamera değiştirme hatası: $e");
                                }
                              }
                            },
                          ),
                        ],
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

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _showEndStreamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Yayını Bitir"),
        content: const Text("Canlı yayını sonlandırmak istediğine emin misin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              Navigator.pop(dialogContext); // Close dialog
              
              // Yayını bitir
              await context.read<LiveStreamProvider>().endStream(widget.roomName);
              
              // Ana ekrana dön
              if (navigator.canPop()) {
                navigator.pop();
              }
            },
            child: const Text("Bitir"),
          ),
        ],
      ),
    );
  }
}
