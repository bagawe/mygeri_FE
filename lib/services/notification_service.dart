import '../models/notification_model.dart';
import 'api_service.dart';

/// NotificationService menggunakan API backend untuk semua operasi notifikasi.
/// Backend otomatis membuat notifikasi saat user lain like/comment postingan.
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _baseUrl = '/api/notifications';
  final _apiService = ApiService();

  /// Get all notifications for current user (from API)
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔔 NotificationService: Fetching notifications from API (page $page)...');
      
      final response = await _apiService.get(
        '$_baseUrl?page=$page&limit=$limit',
      );

      if (response['success'] == true) {
        final List<dynamic> dataList = response['data'] ?? [];
        final notifications = dataList
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ NotificationService: Got ${notifications.length} notifications');
        return notifications;
      } else {
        print('⚠️ NotificationService: API returned success=false');
        return [];
      }
    } catch (e) {
      print('❌ NotificationService: Error fetching notifications - $e');
      return [];
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      print('🔔 NotificationService: Fetching unread count...');
      
      final response = await _apiService.get('$_baseUrl/unread/count');

      if (response['success'] == true) {
        final count = response['data']['count'] ?? 0;
        print('✅ NotificationService: Unread count = $count');
        return count as int;
      }
      return 0;
    } catch (e) {
      print('❌ NotificationService: Error getting unread count - $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      print('🔔 NotificationService: Marking notification $notificationId as read...');
      
      final response = await _apiService.put(
        '$_baseUrl/$notificationId/read',
        {},
      );

      if (response['success'] == true) {
        print('✅ NotificationService: Notification $notificationId marked as read');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ NotificationService: Error marking as read - $e');
      return false;
    }
  }

  /// Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      print('🔔 NotificationService: Marking all notifications as read...');
      
      final response = await _apiService.put(
        '$_baseUrl/read-all',
        {},
      );

      if (response['success'] == true) {
        print('✅ NotificationService: All notifications marked as read');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ NotificationService: Error marking all as read - $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      print('🔔 NotificationService: Deleting notification $notificationId...');
      
      final response = await _apiService.delete('$_baseUrl/$notificationId');

      if (response['success'] == true) {
        print('✅ NotificationService: Notification $notificationId deleted');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ NotificationService: Error deleting notification - $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      print('🔔 NotificationService: Deleting all notifications...');
      
      final response = await _apiService.delete('$_baseUrl/delete-all');

      if (response['success'] == true) {
        print('✅ NotificationService: All notifications deleted');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ NotificationService: Error deleting all - $e');
      return false;
    }
  }

  /// Create notification via API
  /// NOTE: Backend otomatis membuat notifikasi saat like/comment!
  /// Method ini hanya untuk keperluan khusus jika diperlukan.
  @Deprecated('Backend otomatis membuat notifikasi. Gunakan method ini hanya jika perlu manual create.')
  Future<bool> createNotification({
    required String type,
    required int postId,
    required String actorName,
    String actorUsername = '',
    String? content,
    required int targetUserId,
  }) async {
    print('⚠️  NotificationService: createNotification deprecated - backend otomatis membuat notifikasi');
    return false;
  }

  /// Clear local cache (jika diperlukan)
  void clearCache() {
    print('🔄 NotificationService: Cache cleared');
  }
}
