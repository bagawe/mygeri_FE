class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String? senderPhoto;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderPhoto,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] is int
          ? (json['id'] ?? 0)
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      conversationId: json['conversationId'] is int
          ? (json['conversationId'] ?? 0)
          : int.tryParse(json['conversationId']?.toString() ?? '0') ?? 0,
      senderId: json['senderId'] is int
          ? (json['senderId'] ?? 0)
          : int.tryParse(json['senderId']?.toString() ?? '0') ?? 0,
      senderName: json['senderName']?.toString() ?? '',
      senderPhoto: json['senderPhoto']?.toString(),
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String? getFullPhotoUrl(String baseUrl) {
    if (senderPhoto == null || senderPhoto!.isEmpty) return null;
    return '$baseUrl$senderPhoto';
  }

  // Helper untuk format waktu
  String getTimeString() {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
    
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }

  String getFormattedTime() {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
