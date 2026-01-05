class UserHistory {
  final int id;
  final String type;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final int? postId; // ID postingan untuk riwayat yang bisa diklik (mention/tag)

  UserHistory({
    required this.id,
    required this.type,
    this.description,
    this.metadata,
    required this.createdAt,
    this.postId,
  });

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    return UserHistory(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      postId: json['postId'], // ID postingan jika ada
    );
  }

  // Helper untuk cek apakah riwayat ini bisa diklik
  bool get isClickable => postId != null && (type == 'mention' || type == 'tag' || type == 'create_post');
}
