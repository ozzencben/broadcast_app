import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/logic/providers/admin_provider.dart';
import 'package:stream_app/logic/providers/auth_provider.dart';
import 'package:stream_app/logic/wrappers/other_profile_wrapper_for_admin.dart';
import 'package:stream_app/views/widgets/grid_painter.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.clear();

    // Sayfa açıldığında verileri çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers(refresh: true);
    });

    // Liste sonuna gelindiğinde yeni verileri çek (Pagination)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<AdminProvider>().fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('User Management', style: theme.textTheme.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<AdminProvider>().searchUsers(value),
              decoration: const InputDecoration(
                hintText: 'Search username or email...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
      body: GridBackground(
        child: adminProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => adminProvider.fetchUsers(refresh: true),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      adminProvider.users.length +
                      (adminProvider.isFetchingMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // Pagination yükleme göstergesi
                    if (index == adminProvider.users.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final user = adminProvider.users[index];
                    return _buildUserCard(user, theme);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, ThemeData theme) {
    final authProvider = context.read<AuthProvider>();
    final currentAdminId = authProvider.currentUser?.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          if (user.id == currentAdminId) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You cannot view your own profile here."),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherProfileWrapper(user: user),
              ),
            );
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
          backgroundImage:
              user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
              ? Text(
                  user.username[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.username,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: !user.isActive
                      ? TextDecoration.lineThrough
                      : null, // Banlıysa üstünü çiz
                ),
              ),
            ),
            _buildRoleBadge(user),
          ],
        ),
        subtitle: Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: !user.isActive ? Colors.redAccent : Colors.grey,
          ),
        ),
        trailing: _buildActionMenu(user, theme),
      ),
    );
  }

  Widget _buildRoleBadge(UserModel user) {
    String label = 'User';
    Color color = Colors.grey;

    if (user.isAdmin) {
      label = 'Admin';
      color = Colors.amber;
    } else if (user.isStreamer) {
      label = 'Streamer';
      color = AppTheme.accentPurple;
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionMenu(UserModel user, ThemeData theme) {
    // Admin kendi kendini banlamasın diye küçük bir güvenlik
    if (user.isAdmin) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        final provider = context.read<AdminProvider>();
        if (value == 'toggle_status') {
          provider.toggleUserStatus(user.id);
        } else if (value == 'promote_streamer') {
          provider.promoteToStreamer(user.id);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle_status',
          child: Row(
            children: [
              Icon(
                user.isActive ? Icons.block : Icons.check_circle_outline,
                color: user.isActive ? Colors.redAccent : AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(user.isActive ? 'Suspend User' : 'Activate User'),
            ],
          ),
        ),
        if (!user.isStreamer)
          const PopupMenuItem(
            value: 'promote_streamer',
            child: Row(
              children: [
                Icon(
                  Icons.mic_external_on,
                  color: AppTheme.accentPurple,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text('Promote to Streamer'),
              ],
            ),
          ),
      ],
    );
  }
}
