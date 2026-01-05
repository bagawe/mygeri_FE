import 'dart:developer' as developer;
import 'api_service.dart';
import '../models/post.dart';

class SearchService {
  final ApiService _apiService;

  SearchService(this._apiService);

  /// Search posts by keyword
  Future<SearchResult> searchPosts({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      developer.log(
        '🔍 Searching posts: query="$query", page=$page, limit=$limit',
        name: 'SearchService',
      );

      // Validate query
      if (query.trim().isEmpty) {
        throw Exception('Search query cannot be empty');
      }

      if (query.trim().length < 2) {
        throw Exception('Search query must be at least 2 characters');
      }

      final response = await _apiService.get(
        '/api/posts/search?q=${Uri.encodeComponent(query)}&page=$page&limit=$limit',
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Search failed');
      }

      final List<dynamic> postsData = response['data'] ?? [];
      final posts = postsData.map((json) => PostModel.fromJson(json)).toList();

      final pagination = SearchPagination.fromJson(response['pagination'] ?? {});

      developer.log(
        '✅ Search completed: ${posts.length} posts found (total: ${pagination.total})',
        name: 'SearchService',
      );

      return SearchResult(
        posts: posts,
        pagination: pagination,
      );
    } catch (e) {
      developer.log('❌ Search error: $e', name: 'SearchService');
      rethrow;
    }
  }
}

/// Search result container
class SearchResult {
  final List<PostModel> posts;
  final SearchPagination pagination;

  SearchResult({
    required this.posts,
    required this.pagination,
  });
}

/// Pagination information
class SearchPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;
  final String query;

  SearchPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
    required this.query,
  });

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasMore: json['hasMore'] ?? false,
      query: json['query'] ?? '',
    );
  }
}
