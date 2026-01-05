class Hashtag {
  final String hashtag;
  final int count;

  Hashtag({
    required this.hashtag,
    required this.count,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) {
    return Hashtag(
      hashtag: json['hashtag'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hashtag': hashtag,
      'count': count,
    };
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasMore => page < totalPages;

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}

class HashtagPostsResponse {
  final List<dynamic> posts; // Will be parsed to PostModel in service
  final PaginationMeta meta;

  HashtagPostsResponse({
    required this.posts,
    required this.meta,
  });

  factory HashtagPostsResponse.fromJson(Map<String, dynamic> json) {
    return HashtagPostsResponse(
      posts: json['posts'] as List<dynamic>,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts,
      'meta': meta.toJson(),
    };
  }
}
