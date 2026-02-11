import '../models/announcement.dart';
import 'api_service.dart';

class AnnouncementService {
  final ApiService _apiService;

  AnnouncementService(this._apiService);

  Future<List<Announcement>> getAnnouncements() async {
    try {
      print('📢 Fetching announcements...');
      final response = await _apiService.get('/api/announcement', requiresAuth: true);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> announcementList = response['data'];
        return announcementList.map((json) => Announcement.fromJson(json)).toList();
      }
      
      // Handle forbidden error
      if (response['success'] == false && response['message'] != null) {
        if (response['message'].toString().contains('Forbidden') || 
            response['message'].toString().contains('insufficient privileges')) {
          throw Exception('Anda tidak memiliki akses ke fitur My Gerindra. Silakan hubungi admin.');
        }
        throw Exception(response['message']);
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching announcements: $e');
      rethrow;
    }
  }

  Future<Announcement?> getAnnouncementById(int id) async {
    try {
      final response = await _apiService.get('/api/announcement/$id', requiresAuth: true);
      
      if (response['success'] == true && response['data'] != null) {
        return Announcement.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      print('❌ Error fetching announcement detail: $e');
      rethrow;
    }
  }
}
