import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/post.dart';
import 'api_service.dart';
import 'storage_service.dart';

class PostService {
  final ApiService _apiService;
  final StorageService _storage = StorageService();

  PostService(this._apiService);

  // 1. Create Post (Text Only)
  Future<ApiResponse<PostModel>> createPost({
    required String content,
    String? location,
    List<String>? mentions,
  }) async {
    try {
      print('📝 PostService: Creating text post...');
      
      final body = <String, dynamic>{
        'content': content,
      };
      
      if (location != null && location.isNotEmpty) {
        body['location'] = location;
      }
      
      if (mentions != null && mentions.isNotEmpty) {
        body['mentions'] = mentions;
      }
      
      final response = await _apiService.post(
        '/api/posts',
        body,
        requiresAuth: true,
      );

      print('✅ PostService: Post created successfully');
      return ApiResponse<PostModel>(
        success: response['success'],
        data: PostModel.fromJson(response['data']),
        message: response['message'],
      );
    } catch (e) {
      print('❌ PostService: Error creating post - $e');
      return ApiResponse<PostModel>(
        success: false,
        message: 'Gagal membuat postingan: $e',
      );
    }
  }

  // 2. Create Post with Image
  Future<ApiResponse<PostModel>> createPostWithImage({
    String? content,
    required File imageFile,
    String? location,
    List<String>? mentions,
  }) async {
    try {
      print('📝 PostService: Creating post with image...');
      
      final token = await _storage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/posts'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }
      
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      
      if (mentions != null && mentions.isNotEmpty) {
        request.fields['mentions'] = jsonEncode(mentions);
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      print('📤 Uploading image: ${imageFile.path}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('✅ PostService: Post with image created successfully');
        print('📊 Post data: $data');
        return ApiResponse<PostModel>(
          success: data['success'] ?? true,
          data: PostModel.fromJson(data['data']),
          message: data['message'],
        );
      } else {
        print('❌ PostService: Failed to create post - ${data['message']}');
        return ApiResponse<PostModel>(
          success: false,
          message: data['message'] ?? 'Gagal membuat postingan',
        );
      }
    } catch (e, stackTrace) {
      print('❌ PostService: Error creating post with image - $e');
      print('Stack trace: $stackTrace');
      return ApiResponse<PostModel>(
        success: false,
        message: 'Gagal membuat postingan: $e',
      );
    }
  }

  // 2b. Create Post with Multiple Images (NEW)
  Future<ApiResponse<PostModel>> createPostWithMultipleImages({
    String? content,
    required List<File> images,
    String? location,
    List<String>? mentions,
  }) async {
    try {
      print('📝 PostService: Creating post with ${images.length} images...');
      
      final token = await _storage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/posts'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add content
      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }
      
      // Add location
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      
      // Add mentions
      if (mentions != null && mentions.isNotEmpty) {
        request.fields['mentions'] = jsonEncode(mentions);
      }

      // Add multiple images
      for (var i = 0; i < images.length; i++) {
        final multipartFile = await http.MultipartFile.fromPath(
          'images', // Backend expects 'images' field name
          images[i].path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
        print('📎 Added image ${i + 1}/${images.length}: ${images[i].path}');
      }

      print('📤 Uploading ${images.length} images...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ PostService: Post with ${images.length} images created successfully');
        print('📊 Post data: ${data['data']}');
        return ApiResponse<PostModel>(
          success: data['success'] ?? true,
          data: PostModel.fromJson(data['data']),
          message: data['message'],
        );
      } else {
        print('❌ PostService: Failed to create post - ${data['message']}');
        return ApiResponse<PostModel>(
          success: false,
          message: data['message'] ?? 'Gagal membuat postingan',
        );
      }
    } catch (e, stackTrace) {
      print('❌ PostService: Error creating post with multiple images - $e');
      print('Stack trace: $stackTrace');
      return ApiResponse<PostModel>(
        success: false,
        message: 'Gagal membuat postingan: $e',
      );
    }
  }

  // 3. Get Feed
  Future<ApiResponse<List<PostModel>>> getFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🔍 PostService: Getting feed (page: $page, limit: $limit)...');
      final response = await _apiService.get(
        '/api/posts?page=$page&limit=$limit',
        requiresAuth: true,
      );

      final List<PostModel> posts = (response['data'] as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      print('✅ PostService: Retrieved ${posts.length} posts');
      return ApiResponse<List<PostModel>>(
        success: response['success'],
        data: posts,
        pagination: response['pagination'] != null
            ? PaginationModel.fromJson(response['pagination'])
            : null,
      );
    } catch (e) {
      print('❌ PostService: Error getting feed - $e');
      return ApiResponse<List<PostModel>>(
        success: false,
        message: 'Gagal memuat feed: $e',
      );
    }
  }

  // 4. Get Post Detail
  Future<ApiResponse<PostModel>> getPostDetail(int postId) async {
    try {
      print('🔍 PostService: Getting post detail for ID: $postId');
      final response = await _apiService.get(
        '/api/posts/$postId',
        requiresAuth: true,
      );

      print('✅ PostService: Post detail retrieved');
      return ApiResponse<PostModel>(
        success: response['success'],
        data: PostModel.fromJson(response['data']),
      );
    } catch (e) {
      print('❌ PostService: Error getting post detail - $e');
      return ApiResponse<PostModel>(
        success: false,
        message: 'Gagal memuat detail postingan: $e',
      );
    }
  }

  // 5. Toggle Like
  Future<ApiResponse<Map<String, dynamic>>> toggleLike(int postId) async {
    try {
      print('❤️ PostService: Toggling like for post ID: $postId');
      final response = await _apiService.post(
        '/api/posts/$postId/like',
        {},
        requiresAuth: true,
      );

      print('✅ PostService: Like toggled - liked: ${response['liked']}');
      return ApiResponse<Map<String, dynamic>>(
        success: response['success'],
        data: {'liked': response['liked']},
      );
    } catch (e) {
      print('❌ PostService: Error toggling like - $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Gagal like postingan: $e',
      );
    }
  }

  // 6. Add Comment
  Future<ApiResponse<CommentModel>> addComment({
    required int postId,
    required String comment,
  }) async {
    try {
      print('💬 PostService: Adding comment to post ID: $postId');
      print('📝 Comment content: $comment');
      
      final response = await _apiService.post(
        '/api/posts/$postId/comment',
        {'content': comment},  // Backend expects 'content', not 'comment'
        requiresAuth: true,
      );

      print('✅ PostService: Comment added successfully');
      return ApiResponse<CommentModel>(
        success: response['success'],
        data: CommentModel.fromJson(response['data']),
      );
    } catch (e) {
      print('❌ PostService: Error adding comment - $e');
      return ApiResponse<CommentModel>(
        success: false,
        message: 'Gagal menambahkan komentar: $e',
      );
    }
  }

  // 7. Get Comments
  Future<ApiResponse<List<CommentModel>>> getComments({
    required int postId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🔍 PostService: Getting comments for post ID: $postId');
      final response = await _apiService.get(
        '/api/posts/$postId/comments?page=$page&limit=$limit',
        requiresAuth: true,
      );

      final List<CommentModel> comments = (response['data'] as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();

      print('✅ PostService: Retrieved ${comments.length} comments');
      return ApiResponse<List<CommentModel>>(
        success: response['success'],
        data: comments,
        pagination: response['pagination'] != null
            ? PaginationModel.fromJson(response['pagination'])
            : null,
      );
    } catch (e) {
      print('❌ PostService: Error getting comments - $e');
      return ApiResponse<List<CommentModel>>(
        success: false,
        message: 'Gagal memuat komentar: $e',
      );
    }
  }

  // 8. Delete Post
  Future<ApiResponse<void>> deletePost(int postId) async {
    try {
      print('🗑️ PostService: Deleting post ID: $postId');
      final response = await _apiService.delete(
        '/api/posts/$postId',
        requiresAuth: true,
      );

      print('✅ PostService: Post deleted successfully');
      return ApiResponse<void>(
        success: response['success'],
        message: response['message'],
      );
    } catch (e) {
      print('❌ PostService: Error deleting post - $e');
      return ApiResponse<void>(
        success: false,
        message: 'Gagal menghapus postingan: $e',
      );
    }
  }

  // 9. Delete Comment
  Future<ApiResponse<void>> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    try {
      print('🗑️ PostService: Deleting comment ID: $commentId from post ID: $postId');
      final response = await _apiService.delete(
        '/api/posts/$postId/comment/$commentId',
        requiresAuth: true,
      );

      print('✅ PostService: Comment deleted successfully');
      return ApiResponse<void>(
        success: response['success'],
        message: response['message'],
      );
    } catch (e) {
      print('❌ PostService: Error deleting comment - $e');
      return ApiResponse<void>(
        success: false,
        message: 'Gagal menghapus komentar: $e',
      );
    }
  }

  // 10. Share Post (NEW)
  Future<ApiResponse<PostModel>> sharePost({
    required int postId,
    String? comment,
  }) async {
    try {
      print('🔄 PostService: Sharing post ID: $postId');
      
      final body = <String, dynamic>{
        'postId': postId,
      };
      
      if (comment != null && comment.isNotEmpty) {
        body['comment'] = comment;
      }
      
      final response = await _apiService.post(
        '/api/posts/share',
        body,
        requiresAuth: true,
      );

      print('✅ PostService: Post shared successfully');
      return ApiResponse<PostModel>(
        success: response['success'],
        data: PostModel.fromJson(response['data']),
        message: response['message'] ?? 'Post berhasil dibagikan',
      );
    } catch (e) {
      print('❌ PostService: Error sharing post - $e');
      return ApiResponse<PostModel>(
        success: false,
        message: 'Gagal membagikan post: $e',
      );
    }
  }
}
