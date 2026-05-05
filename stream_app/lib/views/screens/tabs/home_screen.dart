import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/providers/notification_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/views/screens/notif_screen.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final authProvider = context.read<AuthProvider>();

      // Eğer AuthProvider zaten kullanıcıyı yüklediyse, UserProvider'a aktaralım (Sync)
      if (authProvider.currentUser != null && userProvider.user == null) {
        // Burada fetchUser yerine direkt userProvider içindeki setter'ı veya benzeri bir şeyi kullanabiliriz
        // Ama şimdilik en azından gereksiz fetch'i önlemek için:
        userProvider.fetchUser();
      }
    });
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

              if (userProvider.errorMessage != null) {
                return _buildErrorState(userProvider, theme);
              }

              final user = userProvider.user;
              if (user == null) {
                return const Center(
                  child: Text('Kullanıcı verisi bulunamadı.'),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst Bar: Hoşgeldin ve Çıkış
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            Text(
                              user.email.split(
                                '@',
                              )[0], // Email'in baş kısmını isim gibi kullanalım
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        // Notif Butonu (Görseldeki yuvarlak buton stili)
                        Consumer<NotificationProvider>(
                          builder: (context, provider, child) {
                            return Badge(
                              isLabelVisible: provider.unreadCount > 0,
                              backgroundColor: AppTheme.accentPurple,
                              label: Text(
                                provider.unreadCount > 99
                                    ? "99+"
                                    : provider.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationScreen(),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Ana Kart: Profil Özeti (Görseldeki yeşil geniş buton havasında)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 40,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Premium Member',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Status: ${user.isActive ? "Active" : "Passive"}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.black87.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bilgi Kartları (Görseldeki alt alta dizilen kutular gibi)
                    _buildInfoCard(
                      theme,
                      icon: Icons.alternate_email_rounded,
                      title: 'Email Address',
                      subtitle: user.email,
                      color: theme.colorScheme.secondary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      theme,
                      icon: Icons.fingerprint_rounded,
                      title: 'User ID',
                      subtitle: '#${user.id}',
                      color: Colors.white,
                    ),

                    const SizedBox(height: 32),

                    // Görseldeki "Create New" butonu gibi bir aksiyon butonu
                    ElevatedButton.icon(
                      onPressed: () {
                        // Bir aksiyon
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Start New Session'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 64),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget: Bilgi Kartı
  Widget _buildInfoCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: color == Colors.white
            ? Border.all(color: Colors.black.withOpacity(0.05))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hata Durumu Widget'ı
  Widget _buildErrorState(UserProvider provider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(provider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => provider.fetchUser(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
