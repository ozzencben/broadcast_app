import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider importu eklendi
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/logic/providers/user_provider.dart'; // Provider importu eklendi
import 'package:stream_app/views/widgets/grid_painter.dart';

class OtherStreamerProfileScreen extends StatefulWidget {
  final UserModel user;

  const OtherStreamerProfileScreen({super.key, required this.user});

  @override
  State<OtherStreamerProfileScreen> createState() =>
      _OtherStreamerProfileScreenState();
}

class _OtherStreamerProfileScreenState
    extends State<OtherStreamerProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Profil sayfasına girildiğinde en güncel veriyi (takip durumu dahil) çekiyoruz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUserProfile(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Provider'ı dinlemeye başlıyoruz
    final userProvider = context.watch<UserProvider>();

    // 2. Güncel kullanıcıyı buluyoruz.
    // Önce arama sonuçlarında, sonra takip listesinde bakıyoruz.
    // Eğer ikisinde de yoksa (direkt link vs), en son fetchUserProfile ile güncellenmiş state'i beklemiş oluruz.
    UserModel currentUserState = widget.user;

    // Arama sonuçlarında var mı?
    final searchIdx = userProvider.searchResults.indexWhere(
      (u) => u.id == widget.user.id,
    );
    if (searchIdx != -1) {
      currentUserState = userProvider.searchResults[searchIdx];
    } else {
      // Takip listesinde var mı?
      final followIdx = userProvider.followingList.indexWhere(
        (u) => u.id == widget.user.id,
      );
      if (followIdx != -1) {
        currentUserState = userProvider.followingList[followIdx];
      }
    }

    // İsim gösterme mantığı (Ad yoksa username)
    final displayName =
        (currentUserState.firstName != null &&
            currentUserState.firstName!.isNotEmpty)
        ? '${currentUserState.firstName} ${currentUserState.lastName ?? ''}'
              .trim()
        : currentUserState.username;

    return Scaffold(
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
      extendBodyBehindAppBar: true,
      body: GridBackground(
        child: SafeArea(
          child: userProvider.isProfileLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () =>
                      userProvider.fetchUserProfile(widget.user.id),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ÜST KISIM: AVATAR VE İSİM ---
                        Row(
                          children: [
                            _buildProfileAvatar(currentUserState, theme),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '@${currentUserState.username}',
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
                        if (currentUserState.bio != null &&
                            currentUserState.bio!.isNotEmpty)
                          Text(
                            currentUserState.bio!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        if (currentUserState.bio != null &&
                            currentUserState.bio!.isNotEmpty)
                          const SizedBox(height: 24),

                        // --- GERÇEK İSTATİSTİKLER ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Sadece yayıncıların takipçileri görünür
                            if (currentUserState.isStreamer)
                              _buildStatItem(
                                'Followers',
                                currentUserState.followersCount.toString(),
                                theme,
                              ),

                            // Sadece normal kullanıcıların kimi takip ettiği görünür (Eğer buraya normal kullanıcı düşerse diye önlem)
                            if (!currentUserState.isStreamer)
                              _buildStatItem(
                                'Following',
                                currentUserState.followingCount.toString(),
                                theme,
                              ),

                            _buildStatItem(
                              'Streams',
                              '86',
                              theme,
                            ), // Burası şimdilik mock kalabilir (stream mimarisi kurulana kadar)
                          ],
                        ),
                        const SizedBox(height: 32),

                        // --- AKSİYON BUTONLARI ---
                        Row(
                          children: [
                            // Sadece yayıncıysa takip butonu göster
                            if (currentUserState.isStreamer)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (currentUserState.isFollowing) {
                                      userProvider.unfollowStreamer(
                                        currentUserState.id,
                                      );
                                    } else {
                                      userProvider.followStreamer(
                                        currentUserState.id,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    // Takip ediyorsa gri, etmiyorsa mor renk
                                    backgroundColor:
                                        currentUserState.isFollowing
                                        ? theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                        : AppTheme.accentPurple,
                                    foregroundColor:
                                        currentUserState.isFollowing
                                        ? AppTheme.primaryGreen
                                        : Colors.white,
                                    elevation: currentUserState.isFollowing
                                        ? 0
                                        : 2,
                                  ),
                                  child: Text(
                                    currentUserState.isFollowing
                                        ? 'UNFOLLOW'
                                        : 'FOLLOW',
                                  ),
                                ),
                              ),
                            if (currentUserState.isStreamer)
                              const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Mesajlaşma işlevi eklenecek
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.lightBackground,
                                  side: BorderSide(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Text('MESSAGE'),
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
        ),
      ),
    );
  }

  // Profil Fotoğrafı Widget'ı (Güvenli Avatar Baş Harfi)
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

  // İstatistik Öğesi
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
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.play_circle_outline,
            color: AppTheme.accentPurple.withValues(alpha: 0.5),
          ),
        );
      },
    );
  }
}
