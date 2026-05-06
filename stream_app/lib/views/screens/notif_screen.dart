import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_app/core/theme.dart';
import 'package:stream_app/data/models/notification/notification_model.dart';
import 'package:stream_app/logic/providers/notification_provider.dart';

// Eğer arka plan grid desenini burada da kullanmak istersen ekleyebilirsin:
// import 'package:stream_app/views/widgets/grid_painter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();

      // SADECE LİSTE BOŞSA API'DEN ÇEK!
      // Böylece WebSocket'ten gelen anlık veriyi ekrandan silmemiş oluruz.
      if (provider.notifications.isEmpty) {
        provider.fetchHistory(isRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Liste sonuna 200 piksel kala yeni verileri çek (Pagination)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context), // Geri dönüş butonu
        ),
        title: Text(
          'Notifications',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Tümünü Okundu İşaretle Butonu
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all_rounded),
            color: AppTheme.accentPurple,
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          // 1. İlk Yükleme Durumu
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Boş Liste Durumu
          if (provider.notifications.isEmpty) {
            return _buildEmptyState(theme);
          }

          // 3. Bildirim Listesi
          return RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () => provider.fetchHistory(isRefresh: true),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount:
                  provider.notifications.length +
                  (provider.hasMoreData ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                // Pagination yükleme indikatörü
                if (index == provider.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = provider.notifications[index];
                return _buildNotificationCard(context, notification, theme);
              },
            ),
          );
        },
      ),
    );
  }

  // Okunmamış veya Okunmuş Bildirim Kartı
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    ThemeData theme,
  ) {
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: () {
        // Okundu olarak işaretle
        if (isUnread) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }

        // TODO: notification.data içeriğine göre (örn: type == 'follow') ilgili profile git
        // Navigator.pushNamed(...)
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Okunmamışsa yeşilimsi/mor hafif transparan bir arkaplan ver
          color: isUnread
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isUnread
              ? Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3))
              : Border.all(color: Colors.transparent),
          boxShadow: [
            if (!isUnread) // Okunmuşlara çok hafif gölge
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon veya Profil Fotoğrafı Alanı
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: isUnread
                    ? AppTheme.primaryGreen
                    : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                image:
                    notification.imageUrl != null &&
                        notification.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(notification.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  notification.imageUrl == null ||
                      notification.imageUrl!.isEmpty
                  ? Icon(
                      _getIconForType(notification.type),
                      color: isUnread ? Colors.black87 : Colors.black54,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Metin ve Tarih Alanı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Okunmamış Bildirim Noktası (Badge)
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Boş Liste Durumu Tasarımı
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no new notifications.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // Tipine göre ikon belirleme
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'follow':
        return Icons.person_add_alt_1_rounded;
      case 'donation':
        return Icons.volunteer_activism_rounded;
      case 'live':
        return Icons.podcasts_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  // Basit Zaman Biçimlendirici (Örn: "2 hours ago")
  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
