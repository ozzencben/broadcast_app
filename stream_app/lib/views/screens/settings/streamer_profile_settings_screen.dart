import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/views/screens/auth/login_screen.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class StreamerSettingsScreen extends StatefulWidget {
  const StreamerSettingsScreen({super.key});

  @override
  State<StreamerSettingsScreen> createState() => _StreamerSettingsScreenState();
}

class _StreamerSettingsScreenState extends State<StreamerSettingsScreen> {
  // Örnek state kontrolleri (Gerçekte backend'e bağlanacak)
  bool _isChatEnabled = true;
  bool _isDonationEnabled = true;
  bool _isSubOnlyMode = false;

  void _saveSettings() {
    // TODO: Backend'e ayarları gönderme işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Streamer settings updated successfully!'),
        backgroundColor: AppTheme.accentPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

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
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // Eğer kullanıcı null ise veya yayıncı değilse (Güvenlik kontrolü)
    if (user == null || !user.isStreamer) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unauthorized')),
        body: const Center(
          child: Text('You must be a streamer to access this page.'),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Streamer Hub',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
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
                // --- Üst Bilgi Kartı ---
                _buildInfoCard(theme, user.username),
                const SizedBox(height: 32),

                Text(
                  'Stream Preferences',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Ayar Seçenekleri (Toggle'lar) ---
                _buildToggleItem(
                  theme: theme,
                  title: 'Enable Live Chat',
                  subtitle: 'Allow viewers to chat during your stream.',
                  icon: Icons.chat_bubble_outline_rounded,
                  value: _isChatEnabled,
                  onChanged: (val) => setState(() => _isChatEnabled = val),
                ),
                const SizedBox(height: 12),

                _buildToggleItem(
                  theme: theme,
                  title: 'Subscriber Only Mode',
                  subtitle: 'Only paid subscribers can watch or chat.',
                  icon: Icons.star_border_rounded,
                  value: _isSubOnlyMode,
                  onChanged: (val) => setState(() => _isSubOnlyMode = val),
                  isPremium: true, // Özel badge gösterecek
                ),
                const SizedBox(height: 12),

                _buildToggleItem(
                  theme: theme,
                  title: 'Accept Donations',
                  subtitle: 'Show donation goals and accept tips.',
                  icon: Icons.volunteer_activism_outlined,
                  value: _isDonationEnabled,
                  onChanged: (val) => setState(() => _isDonationEnabled = val),
                ),

                const SizedBox(height: 32),
                Text(
                  'Stream Keys & Connections',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Alt Menü Öğeleri ---
                _buildActionItem(
                  theme: theme,
                  title: 'Show Stream Key',
                  icon: Icons.key_rounded,
                  onTap: () {
                    // TODO: OBS Stream Key gösterme modalı
                  },
                ),
                const SizedBox(height: 12),
                _buildActionItem(
                  theme: theme,
                  title: 'Setup OBS WebSockets',
                  icon: Icons.cast_connected_rounded,
                  onTap: () {},
                ),

                const SizedBox(height: 48),

                // --- Kaydet Butonu ---
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    'Save Preferences',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        24,
                      ), // Profile uygun yuvarlak
                    ),
                    elevation: 8,
                    shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 28),

                OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Yardımcı Widget'lar (Tasarım Dilini Korumak İçin) ---

  Widget _buildInfoCard(ThemeData theme, String username) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPurple.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.podcasts_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Dashboard',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'channel/$username',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isPremium = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              color: isPremium
                  ? Colors.amber.withValues(alpha: 0.15)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isPremium ? Colors.orange : theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
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
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
            Icon(
              icon,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 22,
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
}
