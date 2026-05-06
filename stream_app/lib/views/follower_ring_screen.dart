import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/logic/wrappers/other_profile_wrapper_for_admin.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class FollowersListScreen extends StatefulWidget {
  const FollowersListScreen({super.key});

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Arama kutusunu dinle
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    // Ekranın ilk çizimi biter bitmez veriyi çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.user;
    if (currentUser != null) {
      userProvider.fetchFollowerList(currentUser.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Takip et / Takipten çık işlevi (Yayıncı da takipçisini geri takip etmek isteyebilir)
  void _toggleFollow(UserModel user) {
    final provider = context.read<UserProvider>();
    final isCurrentlyFollowing = user.isFollowing ?? false;

    if (isCurrentlyFollowing) {
      provider.unfollowStreamer(user.id);
    } else {
      provider.followStreamer(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();

    // Provider'daki takipçi listesini (followerList) kullanıyoruz
    final filteredUsers = userProvider.followerList.where((user) {
      if (_searchQuery.isEmpty) return true;

      final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'
          .toLowerCase();
      final username = user.username.toLowerCase();

      return fullName.contains(_searchQuery) || username.contains(_searchQuery);
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Followers',
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
          child: Column(
            children: [
              // --- Arama Çubuğu (Search Bar) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search followers...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(
                                context,
                              ).unfocus(); // Klavyeyi kapat
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: theme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // --- Liste Alanı ---
              Expanded(
                child:
                    userProvider.isLoading && userProvider.followerList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                    ? _buildEmptyState(
                        theme,
                        isSearchMode: _searchQuery.isNotEmpty,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          // Followers listesinde isFollowing default olarak false olabilir
                          // (çünkü o bizi takip ediyor, biz onu etmiyor olabiliriz)
                          final isFollowing = user.isFollowing ?? false;

                          return _buildUserCard(
                            context,
                            theme,
                            user,
                            isFollowing,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Her Bir Kullanıcı İçin Kart Tasarımı ---
  Widget _buildUserCard(
    BuildContext context,
    ThemeData theme,
    UserModel user,
    bool isFollowing,
  ) {
    // Profil gösterim isimlerini ayarla
    final displayName = (user.firstName != null && user.lastName != null)
        ? '${user.firstName} ${user.lastName}'
        : user.username;

    final initial = (user.firstName != null && user.firstName!.isNotEmpty)
        ? user.firstName![0].toUpperCase()
        : user.username[0].toUpperCase();

    return InkWell(
      onTap: () {
        // --- KRİTİK DEĞİŞİKLİK: Takipçi yayıncı da olabilir, normal user da. Wrapper karar versin. ---
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtherProfileWrapper(user: user)),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar (Resim varsa NetworkImage, yoksa baş harf)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
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
              child:
                  (user.profileImageUrl == null ||
                      user.profileImageUrl!.isEmpty)
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: AppTheme.accentPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 16),

            // İsim ve Kullanıcı Adı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${user.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Arama Sonucu Bulunamadı Tasarımı ---
  Widget _buildEmptyState(ThemeData theme, {required bool isSearchMode}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchMode
                ? Icons.search_off_rounded
                : Icons.people_outline_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            isSearchMode
                ? 'No followers found'
                : 'You don\'t have any followers yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
