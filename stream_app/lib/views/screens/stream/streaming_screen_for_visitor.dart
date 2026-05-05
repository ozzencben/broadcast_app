import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';

class StreamingScreenForVisitor extends StatefulWidget {
  final String roomName;

  const StreamingScreenForVisitor({super.key, required this.roomName});

  @override
  State<StreamingScreenForVisitor> createState() =>
      _StreamingScreenForVisitorState();
}

class _StreamingScreenForVisitorState extends State<StreamingScreenForVisitor> {
  @override
  Widget build(BuildContext context) {
    final streamProvider = context.watch<LiveStreamProvider>();
    final currentStream = streamProvider.currentConnection?.stream;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // 1. MOCK VIDEO AREA (İzleyicinin göreceği yayın)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  // Odadan Çıkış Butonu (Yayını bitirmez, sadece izleyiciyi çıkartır)
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

          // 3. BOTTOM OVERLAY (Viewer Controls - Chat placeholder)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Gelecekte Chat input alanı buraya gelecek
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      "Sohbete katıl...",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Hediye / Beğeni Butonu (Mock)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple,
                    shape: BoxShape.circle,
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
        ],
      ),
    );
  }

  void _leaveStream(BuildContext context) {
    // TODO: LiveKit odasından disconnect olma işlemi eklenecek
    Navigator.pop(context); // Şimdilik sadece sayfadan çıkıyoruz
  }
}
