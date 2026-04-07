class NotificationModel {
  final int id;
  final int userId;
  final String type; // 'like', 'comment'
  final int? postId;
  final int? commentId;
  final String fromUserName;
  final String fromUserUsername;
  final String? message;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.postId,
    this.commentId,
    required this.fromUserName,
    required this.fromUserUsername,
    this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      type: json['type'] as String? ?? 'like',
      postId: json['postId'] as int?,
      commentId: json['commentId'] as int?,
      fromUserName: json['fromUserName'] as String? ?? '',
      fromUserUsername: json['fromUserUsername'] as String? ?? '',
      message: json['message'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'postId': postId,
      'commentId': commentId,
      'fromUserName': fromUserName,
      'fromUserUsername': fromUserUsername,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  String getNotificationText() {
    if (type == 'like') {
      return '$fromUserName menyukai postingan Anda';
    } else if (type == 'comment') {
      return '$fromUserName mengomentari postingan Anda: "$message"';
    }
    return 'Notifikasi baru';
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
