import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/post_service.dart';
import '../../services/api_service.dart';
import '../feed/post_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  final PostService _postService = PostService(ApiService());
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.getNotifications();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = _notificationService.getNotifications();
    });
  }

  void _handleNotificationTap(NotificationModel notification) async {
    print('👆 Tapped on notification: type=${notification.type}, postId=${notification.postId}');
    
    // Mark as read
    await _notificationService.markAsRead(notification.id);

    // Navigate to post if available
    if (notification.postId != null) {
      // Tampilkan loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        // Fetch post detail by ID
        print('📡 Fetching post detail for ID: ${notification.postId}');
        final post = await _postService.getPostById(notification.postId!);
        
        final contentPreview = post.content != null && post.content!.isNotEmpty
            ? (post.content!.length > 30 
                ? '${post.content!.substring(0, 30)}...' 
                : post.content!)
            : '(no content)';
        print('✅ Post loaded successfully: $contentPreview');
        
        // Tutup loading
        if (mounted) Navigator.pop(context);
        
        // Navigate ke detail page
        if (mounted) {
          print('🚀 Navigating to PostDetailPage');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(post: post),
            ),
          );
        }
      } catch (e) {
        print('❌ Error loading post: $e');
        
        // Tutup loading
        if (mounted) Navigator.pop(context);
        
        // Tampilkan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat postingan: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    // Refresh to update UI
    _refreshNotifications();
  }

  void _deleteNotification(int notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    _refreshNotifications();
  }

  void _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            label: const Text('Tandai Semua'),
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: FutureBuilder<List<NotificationModel>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Gagal memuat notifikasi'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshNotifications,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada notifikasi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refreshNotifications,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isUnread = !notification.isRead;
    
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        color: isUnread ? Colors.red.withOpacity(0.05) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getNotificationColor(notification.type).withOpacity(0.1),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.getNotificationText(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.getTimeAgo(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Delete button
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Hapus'),
                  onTap: () => _deleteNotification(notification.id),
                ),
              ],
              child: Icon(Icons.more_vert, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    if (type == 'like') {
      return Icons.favorite;
    } else if (type == 'comment') {
      return Icons.comment;
    }
    return Icons.notifications;
  }

  Color _getNotificationColor(String type) {
    if (type == 'like') {
      return Colors.red;
    } else if (type == 'comment') {
      return Colors.blue;
    }
    return Colors.orange;
  }
}
