import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // 1. MOCK VIDEO AREA
          // Burası ileride LiveKit VideoTrackRenderer olacak
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_off,
                    color: AppTheme.primaryGreen.withOpacity(0.5),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Kamera Hazırlanıyor...",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ),

          // 2. TOP OVERLAY (Stream Info)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: Colors.black.withOpacity(0.5),
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
                  // Kapatma/Yayını Bitir Butonu
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

          // 3. BOTTOM OVERLAY (Controls)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  currentStream?.title ?? "Başlıksız Yayın",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                      onPressed: () =>
                          setState(() => _isMicEnabled = !_isMicEnabled),
                    ),
                    const SizedBox(width: 16),
                    _buildControlButton(
                      icon: _isCamEnabled ? Icons.videocam : Icons.videocam_off,
                      onPressed: () =>
                          setState(() => _isCamEnabled = !_isCamEnabled),
                    ),
                    const SizedBox(width: 16),
                    _buildControlButton(
                      icon: Icons.cameraswitch,
                      onPressed: () {
                        // Kamera çevirme simülasyonu
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          color: Colors.white.withOpacity(0.2),
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
            onPressed: () {
              Navigator.pop(dialogContext); // Dialogu kapat
              context.read<LiveStreamProvider>().endStream(widget.roomName);
              Navigator.pop(context); // Yayından çık
            },
            child: const Text("Bitir"),
          ),
        ],
      ),
    );
  }
}
