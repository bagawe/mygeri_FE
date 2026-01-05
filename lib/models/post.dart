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
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      fotoProfil: json['fotoProfil'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fotoProfil': fotoProfil,
    };
  }
}

class PostModel {
  final int id;
  final String? content;
  final String? imageUrl;  // Legacy: single image (backward compatible)
  final List<String>? imageUrls;  // NEW: multiple images support
  final String? location;  // NEW: Location tagging
  final List<String>? mentions;  // NEW: Tagged usernames (@username)
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  int likeCount;
  int commentCount;
  bool likedByMe;

  PostModel({
    required this.id,
    this.content,
    this.imageUrl,
    this.imageUrls,  // NEW
    this.location,  // NEW
    this.mentions,  // NEW
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse imageUrls array
    List<String>? imageUrls;
    if (json['imageUrls'] != null) {
      if (json['imageUrls'] is List) {
        imageUrls = (json['imageUrls'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }
    
    // Parse mentions array
    List<String>? mentions;
    if (json['mentions'] != null) {
      if (json['mentions'] is List) {
        mentions = (json['mentions'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }
    
    return PostModel(
      id: json['id'] as int? ?? 0,
      content: json['content'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageUrls: imageUrls,  // NEW
      location: json['location'] as String?,  // NEW
      mentions: mentions,  // NEW
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      likedByMe: json['likedByMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,  // NEW
      'location': location,  // NEW
      'mentions': mentions,  // NEW
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'likedByMe': likedByMe,
    };
  }

  // Helper untuk get all image URLs (backward compatible)
  List<String> getAllImageUrls() {
    // Prioritas: imageUrls (new) > imageUrl (legacy)
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return imageUrls!;
    }
    if (imageUrl != null) {
      return [imageUrl!];
    }
    return [];
  }

  // Helper untuk full image URLs dengan base URL
  List<String> getFullImageUrls(String baseUrl) {
    final urls = getAllImageUrls();
    return urls.map((url) {
      // Cek apakah URL sudah full (dengan http/https)
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
      return '$baseUrl$url';
    }).toList();
  }

  // Helper untuk backward compatibility (deprecated, gunakan getAllImageUrls)
  @Deprecated('Use getAllImageUrls() instead')
  String? getFullImageUrl(String baseUrl) {
    final urls = getAllImageUrls();
    if (urls.isEmpty) return null;
    final url = urls.first;
    // Cek apakah URL sudah full
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '$baseUrl$url';
  }
}


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
      id: json['id'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

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
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

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
