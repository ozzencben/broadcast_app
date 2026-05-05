import 'package:flutter/material.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final UserModel user;

  const OtherUserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dinamik isim gösterimi: Ad Soyad varsa o, yoksa username.
    final displayName =
        (user.firstName != null &&
            user.lastName != null &&
            user.firstName!.isNotEmpty)
        ? '${user.firstName} ${user.lastName}'
        : user.username;

    // Avatar için baş harf (Başkalarının profiline bakarken e-posta yerine username baş harfi kullanmak daha güvenlidir)
    final initial = (user.firstName != null && user.firstName!.isNotEmpty)
        ? user.firstName![0].toUpperCase()
        : user.username[0].toUpperCase();

    return Scaffold(
      extendBodyBehindAppBar:
          true, // İçeriğin AppBar'ın altına kaymasını sağlar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: GridBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // --- Avatar ve Profil Kartı ---
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                          // Resim varsa arka plana yerleştiriyoruz
                          image:
                              (user.profileImageUrl != null &&
                                  user.profileImageUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(user.profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        // Sadece resim yoksa baş harfi gösteriyoruz
                        child:
                            (user.profileImageUrl == null ||
                                user.profileImageUrl!.isEmpty)
                            ? Text(
                                initial,
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 48,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),

                      // Ad Soyad
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Username (@handle)
                      Text(
                        '@${user.username}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.primaryColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Biyografi (Varsa gösterilir)
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Durum Badge'leri (Active & Streamer)
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildBadge(
                            theme,
                            label: user.isActive ? 'Active Member' : 'Passive',
                            color: user.isActive
                                ? AppTheme.primaryGreen
                                : Colors.redAccent,
                          ),
                          if (user.isStreamer)
                            _buildBadge(
                              theme,
                              label: 'Streamer',
                              color: AppTheme.accentPurple,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // İleride buraya "Takip Et" (Follow) veya "Mesaj Gönder" gibi
                // başkasının profilinde yapılabilecek aksiyon butonları eklenebilir.
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Şık Badge Tasarımı (Değişmedi, aynı tasarımı kullanıyoruz)
  Widget _buildBadge(
    ThemeData theme, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color.withValues(alpha: 0.9),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
