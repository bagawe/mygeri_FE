import '../models/user_search_result.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  /// Search users by username or name
  Future<List<UserSearchResult>> searchUsers(
    String query, {
    int limit = 20,
    bool excludeSelf = true,
  }) async {
    try {
      print('🔍 UserService: Searching users with query "$query"...');
      
      final response = await _apiService.get(
        '/api/users/search?q=$query&limit=$limit&excludeSelf=$excludeSelf',
        requiresAuth: true,
      );
      
      final users = (response['data'] as List)
          .map((json) => UserSearchResult.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ UserService: ${users.length} users found');
      return users;
    } catch (e) {
      print('❌ UserService: Error searching users - $e');
      rethrow;
    }
  }
}
