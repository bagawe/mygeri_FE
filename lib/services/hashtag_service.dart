import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hashtag.dart';
import '../models/post.dart';
import 'api_service.dart';

class HashtagService {
  final ApiService _apiService;

  HashtagService(this._apiService);

  /// Get trending hashtags (PUBLIC - no auth required)
  /// Returns list of hashtags sorted by count (7 days)
  Future<List<Hashtag>> getTrendingHashtags({int limit = 10}) async {
    try {
      print('🔥 Getting trending hashtags (limit: $limit)...');
      
      final url = Uri.parse('${ApiService.baseUrl}/api/posts/hashtags/trending?limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Trending hashtags response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> hashtagsJson = data['data'] as List<dynamic>;
          final hashtags = hashtagsJson
              .map((json) => Hashtag.fromJson(json as Map<String, dynamic>))
              .toList();
          
          print('✅ Got ${hashtags.length} trending hashtags');
          return hashtags;
        } else {
          throw Exception(data['message'] ?? 'Failed to get trending hashtags');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting trending hashtags: $e');
      rethrow;
    }
  }

  /// Get posts by hashtag (AUTH required)
  /// Returns list of posts containing the hashtag
  Future<Map<String, dynamic>> getPostsByHashtag({
    required String hashtag,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🔍 Getting posts for hashtag: #$hashtag (page: $page)...');
      
      // Remove # if present
      final cleanHashtag = hashtag.replaceAll('#', '');
      
      final endpoint = '/api/posts/hashtag/$cleanHashtag?page=$page&limit=$limit';
      
      final data = await _apiService.get(endpoint, requiresAuth: true);

      print('📡 Hashtag posts response received');

      if (data['success'] == true) {
        final List<dynamic> postsJson = data['data'] as List<dynamic>;
        final posts = postsJson
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Backend returns 'pagination' not 'meta'
        final meta = PaginationMeta.fromJson(
          data['pagination'] as Map<String, dynamic>
        );
        
        print('✅ Got ${posts.length} posts for #$cleanHashtag');
        
        return {
          'posts': posts,
          'meta': meta,
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to get posts');
      }
    } catch (e) {
      print('❌ Error getting posts by hashtag: $e');
      rethrow;
    }
  }

  /// Extract hashtags from text
  /// Returns list of hashtags without # symbol
  static List<String> extractHashtags(String text) {
    final hashtagRegex = RegExp(r'#[\w\u0080-\uFFFF]+');
    final matches = hashtagRegex.allMatches(text);
    
    return matches
        .map((match) => match.group(0)!.substring(1)) // Remove # symbol
        .toList();
  }

  /// Check if text contains hashtags
  static bool hasHashtags(String text) {
    return text.contains(RegExp(r'#[\w\u0080-\uFFFF]+'));
  }
}
