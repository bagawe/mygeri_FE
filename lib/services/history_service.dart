import 'dart:async';
import '../models/user_history.dart';
import 'api_service.dart';

class HistoryService {
  final ApiService _apiService = ApiService();

  Future<List<UserHistory>> getHistory({int page = 1, int limit = 50}) async {
    try {
      print('📜 HistoryService: Getting history (page: $page, limit: $limit)...');
      
      final data = await _apiService.get(
        '/api/history?page=$page&limit=$limit',
        requiresAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('History request timeout');
        },
      );
      
      if (data['success'] == true) {
        final historyList = (data['data'] as List)
            .map((e) => UserHistory.fromJson(e))
            .toList();
        print('✅ HistoryService: ${historyList.length} history items retrieved');
        return historyList;
      } else {
        throw Exception(data['message'] ?? 'Failed to get history');
      }
    } catch (e) {
      print('❌ HistoryService: Error getting history - $e');
      rethrow;
    }
  }

  Future<void> logHistory(String type, {String? description, Map<String, dynamic>? metadata}) async {
    try {
      await _apiService.post(
        '/api/history',
        {
          'type': type,
          if (description != null) 'description': description,
          if (metadata != null) 'metadata': metadata,
        },
        requiresAuth: true,
      ).timeout(const Duration(seconds: 5));
      
      print('✅ HistoryService: History logged - $type');
    } catch (e) {
      print('❌ HistoryService: Error logging history - $e');
      // Don't throw - logging is non-critical
    }
  }
}
