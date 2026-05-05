import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/views/following_ring_screen.dart';
import 'package:stream_app/views/screens/auth/login_screen.dart';
import 'package:stream_app/views/screens/profile/edit_profile_screen.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    context.read<UserProvider>().clearUser();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GridBackground(
        child: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = userProvider.user;
              if (user == null) {
                return const Center(
                  child: Text('Kullanıcı verisi bulunamadı.'),
                );
              }

              // Dinamik isim gösterimi: Ad Soyad varsa o, yoksa username, o da yoksa email.
              final displayName =
                  (user.firstName != null && user.lastName != null)
                  ? '${user.firstName} ${user.lastName}'
                  : user.username;

              // Avatar için baş harf (Ad varsa adın, yoksa emailin)
              final initial =
                  (user.firstName != null && user.firstName!.isNotEmpty)
                  ? user.firstName![0].toUpperCase()
                  : user.email[0].toUpperCase();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Profil Başlığı ---
                    Text('Profile.', style: theme.textTheme.displayLarge),
                    const SizedBox(height: 32),

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
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                              // Resim varsa arka plana yerleştiriyoruz
                              image:
                                  (user.profileImageUrl != null &&
                                      user.profileImageUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        user.profileImageUrl!,
                                      ),
                                      fit: BoxFit
                                          .cover, // Resmi yuvarlağa tam oturtur
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
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontSize: 48,
                                        ),
                                  )
                                : const SizedBox.shrink(), // Resim varken içini boş bırakır
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                                label: user.isActive
                                    ? 'Active Member'
                                    : 'Passive',
                                color: user.isActive
                                    ? AppTheme.accentPurple
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

                    const SizedBox(height: 24), // Badge'lerden sonraki boşluk
                    // --- YENİ EKLENEN: Takip Edilenler (Following) Butonu ---
                    _buildFollowingButton(
                      context,
                      theme,
                      user.followingCount ?? 0,
                    ),

                    const SizedBox(height: 48),

                    // --- Menü Seçenekleri ---
                    Text(
                      'Settings',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildMenuItem(
                      context,
                      title: 'Edit Profile',
                      icon: Icons.edit_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Security & Password',
                      icon: Icons.security_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Payment Methods',
                      icon: Icons.payments_rounded,
                      onTap: () {},
                    ),

                    const SizedBox(height: 48),

                    // --- Çıkış Butonu ---
                    OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Şık Badge Tasarımı
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

  // Menü Öğesi (Hap tasarımına uygun)
  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  // İnce ve Zarif Takip Edilenler Butonu
  Widget _buildFollowingButton(
    BuildContext context,
    ThemeData theme,
    int followingCount,
  ) {
    return Center(
      child: InkWell(
        // YÖNLENDİRME BURADA DEĞİŞTİ
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FollowingListScreen()),
          );
        },
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(100),
            color: Colors.white.withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_alt_outlined,
                size: 18,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                followingCount.toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Following',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
