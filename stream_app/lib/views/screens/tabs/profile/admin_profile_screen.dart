import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/views/screens/admin/user_list_screen.dart';
import 'package:stream_app/views/screens/auth/login_screen.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
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
                return const Center(child: Text('Admin verisi bulunamadı.'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Üst Başlık ve Rozet ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard.', style: theme.textTheme.displayLarge),
                        _buildBadge(
                          theme,
                          label: 'SYSTEM ADMIN',
                          color: Colors.amber,
                          icon: Icons.verified_user_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // --- Admin Bilgi Kartı (Avatar yerine) ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 64,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.email,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Root Access Granted',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // --- Yönetim Araçları Bölümü ---
                    _buildSectionTitle(theme, 'Management Tools'),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      context,
                      title: 'User Management',
                      subtitle: 'Ban, edit or verify users',
                      icon: Icons.people_alt_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Stream Control',
                      subtitle: 'Monitor and manage active streams',
                      icon: Icons.live_tv_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Financial Reports',
                      subtitle: 'Revenue, payouts and taxes',
                      icon: Icons.analytics_rounded,
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // --- Sistem Ayarları Bölümü ---
                    _buildSectionTitle(theme, 'System Config'),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      context,
                      title: 'App Settings',
                      subtitle: 'Maintenance mode & globals',
                      icon: Icons.settings_suggest_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Server Status',
                      subtitle: 'Latency and infrastructure logs',
                      icon: Icons.dns_rounded,
                      onTap: () {},
                    ),

                    const SizedBox(height: 48),

                    // --- Çıkış Butonu ---
                    OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(
                        Icons.power_settings_new_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text('Secure Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildBadge(
    ThemeData theme, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
