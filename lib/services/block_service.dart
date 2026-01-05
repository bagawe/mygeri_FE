import 'dart:developer' as developer;
import 'api_service.dart';
import '../models/block_user.dart';

class BlockService {
  final ApiService _apiService;

  BlockService(this._apiService);

  /// Block a user
  Future<void> blockUser(int userId) async {
    try {
      developer.log('Blocking user: $userId', name: 'BlockService');
      
      final response = await _apiService.post(
        '/api/users/block',
        {'blockedUserId': userId},
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to block user');
      }

      developer.log('User blocked successfully', name: 'BlockService');
    } catch (e) {
      developer.log('Error blocking user: $e', name: 'BlockService');
      rethrow;
    }
  }

  /// Unblock a user
  Future<void> unblockUser(int userId) async {
    try {
      developer.log('Unblocking user: $userId', name: 'BlockService');
      
      final response = await _apiService.delete(
        '/api/users/block/$userId',
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to unblock user');
      }

      developer.log('User unblocked successfully', name: 'BlockService');
    } catch (e) {
      developer.log('Error unblocking user: $e', name: 'BlockService');
      rethrow;
    }
  }

  /// Get list of blocked users
  Future<List<BlockUser>> getBlockedUsers() async {
    try {
      developer.log('Fetching blocked users', name: 'BlockService');
      
      final response = await _apiService.get(
        '/api/users/blocked',
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch blocked users');
      }

      final List<dynamic> data = response['data'] ?? [];
      final blockedUsers = data.map((json) => BlockUser.fromJson(json)).toList();
      developer.log('Fetched \\${blockedUsers.length} blocked users', name: 'BlockService');
      return blockedUsers;
    } catch (e) {
      developer.log('Error fetching blocked users: $e', name: 'BlockService');
      rethrow;
    }
  }

  /// Check block status with a specific user
  Future<Map<String, bool>> checkBlockStatus(int userId) async {
    try {
      developer.log('Checking block status with user: $userId', name: 'BlockService');
      
      final response = await _apiService.get(
        '/api/users/block-status/$userId',
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to check block status');
      }

      final data = response['data'];
      return {
        'isBlockedByMe': data['isBlockedByMe'] ?? false,
        'isBlockingMe': data['isBlockingMe'] ?? false,
      };
    } catch (e) {
      developer.log('Error checking block status: $e', name: 'BlockService');
      rethrow;
    }
  }
}
