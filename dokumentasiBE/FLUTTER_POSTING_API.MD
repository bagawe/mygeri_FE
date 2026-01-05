# 📱 Flutter Integration Guide - Posting Feature API

Dokumentasi lengkap integrasi API Posting untuk Flutter Developer.

---

## 🔗 Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3030/api';
  
  // Ganti dengan IP server untuk testing di device
  // static const String baseUrl = 'http://192.168.1.100:3030/api';
  
  // Production
  // static const String baseUrl = 'https://api.mygeri.com/api';
}
```

---

## 🔐 Authentication Header

Semua endpoint membutuhkan JWT token di header:

```dart
final headers = {
  'Authorization': 'Bearer $accessToken',
  'Content-Type': 'application/json',
};
```

---

## 📋 Table of Contents

1. [Models](#models)
2. [API Service](#api-service)
3. [Endpoints](#endpoints)
   - [Create Post](#1-create-post)
   - [Get Feed](#2-get-feed)
   - [Get Post Detail](#3-get-post-detail)
   - [Toggle Like](#4-toggle-like)
   - [Add Comment](#5-add-comment)
   - [Get Comments](#6-get-comments)
   - [Delete Post](#7-delete-post)
   - [Delete Comment](#8-delete-comment)
4. [Error Handling](#error-handling)
5. [Example Usage](#example-usage)

---

## 📦 Models

### **User Model**
```dart
class UserModel {
  final int id;
  final String username;
  final String? fotoProfil;

  UserModel({
    required this.id,
    required this.username,
    this.fotoProfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      fotoProfil: json['fotoProfil'],
    );
  }
}
```

### **Post Model**
```dart
class PostModel {
  final int id;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;

  PostModel({
    required this.id,
    this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: UserModel.fromJson(json['user']),
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      likedByMe: json['likedByMe'],
    );
  }

  // Helper untuk full image URL
  String? get fullImageUrl {
    if (imageUrl == null) return null;
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl';
  }
}
```

### **Comment Model**
```dart
class CommentModel {
  final int id;
  final String comment;
  final DateTime createdAt;
  final UserModel user;

  CommentModel({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      user: UserModel.fromJson(json['user']),
    );
  }
}
```

### **Pagination Model**
```dart
class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
```

### **API Response Model**
```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final PaginationModel? pagination;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}
```

---

## 🔌 API Service

### **Post Service Class**

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class PostService {
  final String _baseUrl = '${ApiConfig.baseUrl}/posts';
  
  // Token management (bisa dari SharedPreferences atau State Management)
  String? _accessToken;
  
  void setToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
  };

  // 1. Create Post (Text Only)
  Future<ApiResponse<PostModel>> createPost({
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({'content': content}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<PostModel>(
          success: data['success'],
          data: PostModel.fromJson(data['data']),
        );
      } else {
        return ApiResponse<PostModel>(
          success: false,
          message: data['message'] ?? 'Failed to create post',
        );
      }
    } catch (e) {
      return ApiResponse<PostModel>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // 2. Create Post with Image
  Future<ApiResponse<PostModel>> createPostWithImage({
    String? content,
    required File imageFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_baseUrl),
      );

      request.headers['Authorization'] = 'Bearer $_accessToken';

      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<PostModel>(
          success: data['success'],
          data: PostModel.fromJson(data['data']),
        );
      } else {
        return ApiResponse<PostModel>(
          success: false,
          message: data['message'] ?? 'Failed to create post',
        );
      }
    } catch (e) {
      return ApiResponse<PostModel>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // 3. Get Feed
  Future<ApiResponse<List<PostModel>>> getFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?page=$page&limit=$limit'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<PostModel> posts = (data['data'] as List)
            .map((json) => PostModel.fromJson(json))
            .toList();

        return ApiResponse<List<PostModel>>(
          success: data['success'],
          data: posts,
          pagination: PaginationModel.fromJson(data['pagination']),
        );
      } else {
        return ApiResponse<List<PostModel>>(
          success: false,
          message: data['message'] ?? 'Failed to get feed',
        );
      }
    } catch (e) {
      return ApiResponse<List<PostModel>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // 4. Get Post Detail
  Future<ApiResponse<PostModel>> getPostDetail(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$postId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<PostModel>(
          success: data['success'],
          data: PostModel.fromJson(data['data']),
        );
      } else {
        return ApiResponse<PostModel>(
          success: false,
          message: data['message'] ?? 'Failed to get post detail',
        );
      }
    } catch (e) {
      return ApiResponse<PostModel>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // 5. Toggle Like
  Future<ApiResponse<Map<String, dynamic>>> toggleLike(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$postId/like'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: data['success'],
          data: {'liked': data['liked']},
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: data['message'] ?? 'Failed to toggle like',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // 6. Add Comment
  Future<ApiResponse<CommentModel>> addComment({
    required int postId,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$postId/comment'),
        headers: _headers,
        body: jsonEncode({'comment': comment}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<CommentModel>(
          success: data['success'],
          data: CommentModel.fromJson(data['data']),
        );
      } else {
        return ApiResponse<CommentModel>(
          success: false,
          message: data['message'] ?? 'Failed to add comment',
        );
      }
    } catch (e) {
      return ApiResponse<CommentModel>(
        success: false,
        message: 'Network error: $e',
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
      final response = await http.get(
        Uri.parse('$_baseUrl/$postId/comments?page=$page&limit=$limit'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<CommentModel> comments = (data['data'] as List)
            .map((json) => CommentModel.fromJson(json))
            .toList();

        return ApiResponse<List<CommentModel>>(
          success: data['success'],
          data: comments,
          pagination: PaginationModel.fromJson(data['pagination']),
        );
      } else {
        return ApiResponse<List<CommentModel>>(
          success: false,
          message: data['message'] ?? 'Failed to get comments',
        );
      }
    } catch (e) {
      return ApiResponse<List<CommentModel>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // 8. Delete Post
  Future<ApiResponse<void>> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$postId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      return ApiResponse<void>(
        success: data['success'],
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // 9. Delete Comment
  Future<ApiResponse<void>> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$postId/comment/$commentId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      return ApiResponse<void>(
        success: data['success'],
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
```

---

## 📝 Endpoints

### **1. Create Post**

#### **Text Only**
```dart
final result = await postService.createPost(
  content: 'Ini postingan pertama saya!',
);

if (result.success) {
  print('Post created: ${result.data!.id}');
} else {
  print('Error: ${result.message}');
}
```

#### **With Image**
```dart
import 'package:image_picker/image_picker.dart';

// Pick image
final picker = ImagePicker();
final pickedFile = await picker.pickImage(source: ImageSource.gallery);

if (pickedFile != null) {
  final result = await postService.createPostWithImage(
    content: 'Post dengan gambar',
    imageFile: File(pickedFile.path),
  );

  if (result.success) {
    print('Post created with image: ${result.data!.imageUrl}');
  }
}
```

#### **Image Only (No Text)**
```dart
final result = await postService.createPostWithImage(
  imageFile: File(pickedFile.path),
);
```

---

### **2. Get Feed**

```dart
// Load first page
final result = await postService.getFeed(page: 1, limit: 10);

if (result.success) {
  List<PostModel> posts = result.data!;
  PaginationModel pagination = result.pagination!;
  
  print('Total posts: ${pagination.total}');
  print('Has next page: ${pagination.hasNextPage}');
}
```

#### **Infinite Scroll Implementation**
```dart
class FeedController extends GetxController {
  final PostService _postService = PostService();
  
  final posts = <PostModel>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  int currentPage = 1;

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      posts.clear();
    }

    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    final result = await _postService.getFeed(
      page: currentPage,
      limit: 10,
    );

    isLoading.value = false;

    if (result.success) {
      posts.addAll(result.data!);
      hasMore.value = result.pagination!.hasNextPage;
      currentPage++;
    }
  }
}
```

---

### **3. Get Post Detail**

```dart
final result = await postService.getPostDetail(postId);

if (result.success) {
  PostModel post = result.data!;
  print('Post by: ${post.user.username}');
  print('Likes: ${post.likeCount}');
  print('Comments: ${post.commentCount}');
}
```

---

### **4. Toggle Like**

```dart
// Like/Unlike post
final result = await postService.toggleLike(postId);

if (result.success) {
  bool isLiked = result.data!['liked'];
  print(isLiked ? 'Post liked' : 'Post unliked');
  
  // Update UI
  setState(() {
    post.likedByMe = isLiked;
    post.likeCount += isLiked ? 1 : -1;
  });
}
```

#### **Optimistic Update (Recommended)**
```dart
Future<void> toggleLike(PostModel post) async {
  // Update UI immediately
  setState(() {
    post.likedByMe = !post.likedByMe;
    post.likeCount += post.likedByMe ? 1 : -1;
  });

  // Send request to server
  final result = await postService.toggleLike(post.id);

  // Rollback if failed
  if (!result.success) {
    setState(() {
      post.likedByMe = !post.likedByMe;
      post.likeCount += post.likedByMe ? 1 : -1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Failed to like post')),
    );
  }
}
```

---

### **5. Add Comment**

```dart
final result = await postService.addComment(
  postId: postId,
  comment: commentController.text.trim(),
);

if (result.success) {
  CommentModel newComment = result.data!;
  print('Comment added: ${newComment.id}');
  
  // Clear input
  commentController.clear();
  
  // Refresh comments or add to list
  comments.insert(0, newComment);
}
```

---

### **6. Get Comments**

```dart
final result = await postService.getComments(
  postId: postId,
  page: 1,
  limit: 10,
);

if (result.success) {
  List<CommentModel> comments = result.data!;
  PaginationModel pagination = result.pagination!;
}
```

---

### **7. Delete Post**

```dart
// Show confirmation dialog first
final confirm = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Delete Post'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('Delete'),
      ),
    ],
  ),
);

if (confirm == true) {
  final result = await postService.deletePost(postId);
  
  if (result.success) {
    // Remove from list
    posts.removeWhere((p) => p.id == postId);
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Failed to delete')),
    );
  }
}
```

---

### **8. Delete Comment**

```dart
final result = await postService.deleteComment(
  postId: postId,
  commentId: commentId,
);

if (result.success) {
  // Remove from list
  comments.removeWhere((c) => c.id == commentId);
}
```

---

## ⚠️ Error Handling

### **Common Error Responses**

```dart
// 400 Bad Request
{
  "success": false,
  "message": "Content or image is required"
}

// 401 Unauthorized
{
  "success": false,
  "message": "Invalid token"
}

// 403 Forbidden
{
  "success": false,
  "message": "Access denied"
}

// 404 Not Found
{
  "success": false,
  "message": "Post not found"
}
```

### **Error Handling Pattern**

```dart
Future<void> handleApiCall() async {
  try {
    final result = await postService.getFeed();
    
    if (result.success) {
      // Success
      posts.value = result.data!;
    } else {
      // API returned error
      showError(result.message ?? 'Unknown error');
    }
  } catch (e) {
    // Network error or exception
    showError('Network error: $e');
  }
}

void showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

---

## 💡 Example Usage

### **Complete Feed Screen Example**

```dart
class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();
  
  List<PostModel> posts = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _postService.setToken('YOUR_ACCESS_TOKEN');
    _loadFeed();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadFeed();
    }
  }

  Future<void> _loadFeed() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final result = await _postService.getFeed(
      page: currentPage,
      limit: 10,
    );

    setState(() => isLoading = false);

    if (result.success) {
      setState(() {
        posts.addAll(result.data!);
        hasMore = result.pagination!.hasNextPage;
        currentPage++;
      });
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      posts.clear();
      currentPage = 1;
      hasMore = true;
    });
    await _loadFeed();
  }

  Future<void> _toggleLike(PostModel post) async {
    final originalLiked = post.likedByMe;
    final originalCount = post.likeCount;

    // Optimistic update
    setState(() {
      post.likedByMe = !post.likedByMe;
      post.likeCount += post.likedByMe ? 1 : -1;
    });

    final result = await _postService.toggleLike(post.id);

    // Rollback if failed
    if (!result.success) {
      setState(() {
        post.likedByMe = originalLiked;
        post.likeCount = originalCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed')),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: posts.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == posts.length) {
              return Center(child: CircularProgressIndicator());
            }

            final post = posts[index];
            
            return PostCard(
              post: post,
              onLike: () => _toggleLike(post),
              onComment: () => _navigateToComments(post),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToComments(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(post: post),
      ),
    );
  }

  void _navigateToCreatePost() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostScreen()),
    );

    if (created == true) {
      _refreshFeed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 🎨 UI Components

### **Post Card Widget**

```dart
class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.user.fotoProfil != null
                  ? NetworkImage(post.user.fotoProfil!)
                  : null,
              child: post.user.fotoProfil == null
                  ? Text(post.user.username[0].toUpperCase())
                  : null,
            ),
            title: Text(post.user.username),
            subtitle: Text(_formatDate(post.createdAt)),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showOptions(context),
            ),
          ),

          // Content
          if (post.content != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post.content!),
            ),

          // Image
          if (post.imageUrl != null)
            Image.network(
              post.fullImageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          // Actions
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.likedByMe ? Colors.red : null,
                  ),
                  onPressed: onLike,
                ),
                Text('${post.likeCount}'),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.comment_outlined),
                  onPressed: onComment,
                ),
                Text('${post.commentCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showOptions(BuildContext context) {
    // Show bottom sheet with options
  }
}
```

---

## 📦 Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  http_parser: ^4.0.2
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
```

---

## 🔧 Testing Backend from Flutter

### **Test Connection**

```dart
Future<void> testConnection() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/health'),
    );
    
    if (response.statusCode == 200) {
      print('✅ Backend connected');
    } else {
      print('❌ Backend error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Connection failed: $e');
  }
}
```

### **Common Issues**

1. **Connection Refused** (iOS Simulator)
   - Ganti `localhost` dengan `127.0.0.1`

2. **Connection Refused** (Android Emulator)
   - Ganti `localhost` dengan `10.0.2.2`

3. **Connection Refused** (Real Device)
   - Gunakan IP komputer (misal: `192.168.1.100`)
   - Pastikan device dan komputer di network yang sama

---

## 📱 Platform Specific Notes

### **iOS**

Add to `Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Need access to select photos for posts</string>
<key>NSCameraUsageDescription</key>
<string>Need access to camera for taking photos</string>
```

### **Android**

Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## 🚀 Best Practices

1. **Token Management**
   - Store token di `SharedPreferences` atau `FlutterSecureStorage`
   - Auto-refresh token sebelum expired
   - Clear token saat logout

2. **Image Optimization**
   - Compress image sebelum upload
   - Gunakan `cached_network_image` untuk caching
   - Tampilkan placeholder saat loading

3. **Pagination**
   - Gunakan infinite scroll untuk UX lebih baik
   - Preload data sebelum user scroll sampai bawah

4. **Error Handling**
   - Tampilkan error message yang user-friendly
   - Retry mechanism untuk network error
   - Offline mode (cache data lokal)

5. **Performance**
   - Lazy load images
   - Debounce like/unlike actions
   - Use `ListView.builder` untuk large lists

---

## 📞 Support

Jika ada masalah saat integrasi:

1. Cek log di terminal backend
2. Test endpoint dengan Postman/curl dulu
3. Pastikan token tidak expired
4. Cek network connectivity

---

## 📄 Changelog

- **v1.0.0** (2025-12-27): Initial release
  - Create post (text & image)
  - Feed with pagination
  - Like/Unlike toggle
  - Comments (add, get, delete)
  - Delete post

---

**Happy Coding! 🚀**

Jika ada pertanyaan, silakan hubungi backend team.