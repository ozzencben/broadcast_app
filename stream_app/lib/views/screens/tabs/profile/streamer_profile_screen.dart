import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/locator.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/data/services/permisson_service.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/logic/wrappers/stream_wrapper.dart';
import 'package:stream_app/views/screens/settings/streamer_profile_settings_screen.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class StreamerProfileScreen extends StatelessWidget {
  const StreamerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    // İsim gösterme mantığı (Ad yoksa username)
    final displayName = (user.firstName != null && user.firstName!.isNotEmpty)
        ? '${user.firstName} ${user.lastName ?? ''}'.trim()
        : user.username;

    return Scaffold(
      // Ayarlar butonu AppBar'da sağ üstte kalsın
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StreamerSettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GridBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ÜST KISIM: AVATAR VE İSİM ---
              Row(
                children: [
                  _buildProfileAvatar(user, theme),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${user.username}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- BİYO ---
              if (user.bio != null && user.bio!.isNotEmpty)
                Text(user.bio!, style: theme.textTheme.bodyMedium),
              if (user.bio != null && user.bio!.isNotEmpty)
                const SizedBox(height: 24),

              // --- GERÇEK İSTATİSTİKLER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Eğer kullanıcı bir yayıncıysa takipçilerini göster
                  if (user.isStreamer)
                    _buildStatItem(
                      'Followers',
                      user.followersCount.toString(),
                      theme,
                    ),

                  // Eğer normal bir kullanıcıysa kimleri takip ettiğini göster
                  if (!user.isStreamer)
                    _buildStatItem(
                      'Following',
                      user.followingCount.toString(),
                      theme,
                    ),

                  // Şimdilik yayın sayısı mock olarak kalıyor
                  _buildStatItem('Streams', '86', theme),
                ],
              ),
              const SizedBox(height: 32),

              // --- AKSİYON BUTONLARI ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final permissonServie = locator<PermissionService>();
                        final statuses = await permissonServie.requestMultiple([
                          AppPermission.camera,
                          AppPermission.microphone,
                        ]);
                        final allGranted = statuses.values.every(
                          (isGranted) => isGranted,
                        );

                        if (!context.mounted) return;

                        if (allGranted) {
                          _showGoLiveModal(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Yayın için kamera ve mikrofon izni gereklidir.',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('GO LIVE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Profil düzenleme sayfasına yönlendirme
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.lightBackground,
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: const Text('EDIT'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- MEDYA GRID BAŞLIĞI ---
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'LATEST CLIPS',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- INSTAGRAM TARZI GRID ---
              _buildMediaGrid(theme),
            ],
          ),
        ),
      ),
    );
  }

  // Profil Fotoğrafı Widget'ı (Baş harf destekli güncel versiyon)
  Widget _buildProfileAvatar(UserModel user, ThemeData theme) {
    final initial = (user.firstName != null && user.firstName!.isNotEmpty)
        ? user.firstName![0].toUpperCase()
        : user.username[0].toUpperCase();

    final hasImage =
        user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: theme.primaryColor, width: 3),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(user.profileImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: !hasImage
          ? Text(
              initial,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            )
          : null,
    );
  }

  // İstatistik Öğesi (Takipçi Sayısı vb.)
  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  // Instagram Tarzı 3'lü Grid
  Widget _buildMediaGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9, // Örnek olarak 9 kutu
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            // Buraya gerçek clip/fotoğraf thumbnail'ları gelecek
          ),
          child: Icon(
            Icons.play_circle_outline,
            color: AppTheme.accentPurple.withValues(alpha: 0.5),
          ),
        );
      },
    );
  }

  void _showGoLiveModal(BuildContext context) {
    final titleController = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavyenin üstünde durması için
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (modalContext) {
        return Padding(
          // Klavyenin üstünde kalmasını sağlamak için bottom padding
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yayını Başlat',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'İzleyicilerin ilgisini çekecek bir başlık gir.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Örn: Gece Kodlaması & Sohbet',
                  filled: true,
                  fillColor: AppTheme.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    // 1. KRİTİK DÜZELTME: Provider'ı ve diğer context bazlı işlemleri
                    // modalı kapatmadan ve async boşluğa düşmeden ÖNCE değişkene alıyoruz.
                    final provider = context.read<LiveStreamProvider>();

                    // 2. Artık modalı güvenle kapatabiliriz.
                    Navigator.pop(modalContext);

                    // 3. API isteğini atıyoruz.
                    final success = await provider.startStream(title);

                    // 4. Ana sayfa (StreamerProfileScreen) hala aktif mi kontrol ediyoruz.
                    if (!context.mounted) return;

                    if (success && provider.currentConnection != null) {
                      // API başarılı, Token ve RoomName elimizde. Uçuşa geç!
                      final roomName =
                          provider.currentConnection!.stream.roomName;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StreamWrapper(roomName: roomName),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Yayın başlatılamadı. Lütfen tekrar dene.',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text('CANLI YAYINA GEÇ'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
