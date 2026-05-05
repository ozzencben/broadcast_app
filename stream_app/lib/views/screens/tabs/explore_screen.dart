import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/models/stream/stream_model.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/providers/stream_provider.dart';
import 'package:stream_app/logic/providers/user_provider.dart';
import 'package:stream_app/logic/wrappers/stream_wrapper.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Ekran ilk açıldığında aktif yayınları backend'den çekiyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final streamProvider = context.read<LiveStreamProvider>();
      streamProvider.connectWebSocket();
      streamProvider.fetchActiveStreams(isRefresh: true);

      // Hata dinleyici ekleyelim
      streamProvider.addListener(_onStreamProviderError);
    });
  }

  void _onStreamProviderError() {
    if (mounted) {
      final message = context.read<LiveStreamProvider>().errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    context.read<LiveStreamProvider>().removeListener(_onStreamProviderError);
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<UserProvider>().searchUsers(value);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    FocusScope.of(context).unfocus();
    context.read<UserProvider>().clearSearch();
  }

  // YAYINA KATILMA FONKSİYONU
  void _handleJoinStream(String roomName) async {
    // Tıklanınca klavyeyi kapatalım (açıksa)
    FocusScope.of(context).unfocus();

    final provider = context.read<LiveStreamProvider>();
    final success = await provider.joinStream(roomName);

    if (mounted && success) {
      // Wrapper'a gönderiyoruz, o yayıncı mı izleyici mi olduğuna karar verecek
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StreamWrapper(roomName: roomName)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yayına katılamadınız. Yayın bitmiş olabilir.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: GridBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Explore.', style: theme.textTheme.displayLarge),
                const SizedBox(height: 8),
                Text(
                  'Discover live streams and creators',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSearchBar(theme),
                const SizedBox(height: 24),

                // DEĞİŞİKLİK BURADA: Arama boşsa yayınları göster, doluysa kullanıcıları
                Expanded(
                  child: _searchQuery.isEmpty
                      ? _buildLiveStreamsFeed(theme)
                      : _buildRealUserList(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search users or streamers...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // 1. GÜNCEL FEED METODU
  Widget _buildLiveStreamsFeed(ThemeData theme) {
    return Consumer<LiveStreamProvider>(
      builder: (context, provider, child) {
        // Hata ayıklama logun harika, aynen kalsın
        debugPrint(
          "ExploreScreen: Active Streams Count: ${provider.activeStreams.length}, Loading: ${provider.isLoading}",
        );

        if (provider.isLoading && provider.activeStreams.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // RefreshIndicator'ı EN DIŞA alıyoruz ki boşken de dolsun
        return RefreshIndicator(
          onRefresh: () => provider.fetchActiveStreams(isRefresh: true),
          child: provider.activeStreams.isEmpty
              // EĞER LİSTE BOŞSA: Kaydırılabilir (Pull-to-refresh) Empty State
              ? CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyStateContent(theme),
                    ),
                  ],
                )
              // EĞER LİSTE DOLUYSA: Senin mevcut ListView'ın
              : ListView.separated(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: provider.activeStreams.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final stream = provider.activeStreams[index];
                    return _buildStreamCard(theme, stream);
                  },
                ),
        );
      },
    );
  }

  // 2. GÜNCEL BOŞ DURUM (Empty State) METODU
  // Not: Artık SingleChildScrollView'a ihtiyacı yok, CustomScrollView onu hallediyor.
  Widget _buildEmptyStateContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.travel_explore_rounded,
            size: 64,
            color: AppTheme.accentPurple.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'No active streams right now',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Search for users to view their profiles\nor start your own stream!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // YENİ: YAYIN KARTI TASARIMI
  Widget _buildStreamCard(ThemeData theme, StreamModel stream) {
    return InkWell(
      onTap: () => _handleJoinStream(stream.roomName),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height:
            200, // Şimdilik sabit yükseklik, ileride aspect ratio yapılabilir
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            // Görüntü gelene kadar mock bir arkaplan
            image: NetworkImage(
              'https://images.unsplash.com/photo-1542204165-65bf26472b9b?q=80&w=1000',
            ),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ÜST KISIM: CANLI Rozeti ve İzleyici Sayısı
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.remove_red_eye,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stream.viewerCount ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ALT KISIM: Yayın Başlığı ve Yayıncı Bilgisi
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream.title ?? 'İsimsiz Yayın',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'By ${stream.streamer?.username ?? 'Unknown'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Senin _buildEmptyState ve _buildRealUserList kodların aynı şekilde duruyor)
  Widget _buildEmptyState(ThemeData theme) {
    // ... senin yazdığın ikonlu empty state kodları ...
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                size: 64,
                color: AppTheme.accentPurple.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No active streams right now',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for users to view their profiles\nor start your own stream!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealUserList(ThemeData theme) {
    // ... senin kodunun birebir aynısı ...
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = provider.searchResults;
        if (users.isEmpty && _searchQuery.isNotEmpty) {
          return Center(child: Text('No users found for "$_searchQuery"'));
        }
        return ListView.separated(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildUserCard(theme, users[index]);
          },
        );
      },
    );
  }

  Widget _buildUserCard(ThemeData theme, UserModel user) {
    final authProvider = context.read<AuthProvider>();
    final isMe = authProvider.currentUser?.id == user.id;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user.followersCount} followers',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (!isMe)
            ElevatedButton(
              onPressed: () {
                final provider = context.read<UserProvider>();
                if (user.isFollowing) {
                  provider.unfollowStreamer(user.id);
                } else {
                  provider.followStreamer(user.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isFollowing
                    ? Colors.grey.shade200
                    : theme.primaryColor,
                foregroundColor: user.isFollowing
                    ? Colors.black87
                    : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(user.isFollowing ? 'Following' : 'Follow'),
            ),
        ],
      ),
    );
  }
}
