import 'message.dart';

class ConversationParticipant {
  final int id;
  final String username;
  final String name;
  final String? fotoProfil;

  ConversationParticipant({
    required this.id,
    required this.username,
    required this.name,
    this.fotoProfil,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id'] is int
          ? (json['id'] ?? 0)
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fotoProfil: json['fotoProfil']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'fotoProfil': fotoProfil,
    };
  }

  String? getFullPhotoUrl(String baseUrl) {
    if (fotoProfil == null || fotoProfil!.isEmpty) return null;
    return '$baseUrl$fotoProfil';
  }
}

class Conversation {
  final int id;
  final String uuid;
  final ConversationParticipant otherParticipant;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.uuid,
    required this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] is int
          ? (json['id'] ?? 0)
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      uuid: json['uuid']?.toString() ?? '',
      otherParticipant: ConversationParticipant.fromJson(
        json['otherParticipant'] as Map<String, dynamic>,
      ),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] is int
          ? (json['unreadCount'] ?? 0)
          : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'otherParticipant': otherParticipant.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper untuk format waktu last message
  String getLastMessageTime() {
    if (lastMessage == null) return '';
    
    final now = DateTime.now();
    final messageTime = lastMessage!.createdAt;
    final diff = now.difference(messageTime);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays}h lalu';
      return '${messageTime.day}/${messageTime.month}';
    }
    
    final hour = messageTime.hour.toString().padLeft(2, '0');
    final minute = messageTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String getLastMessagePreview() {
    if (lastMessage == null) return 'Belum ada pesan';
    return lastMessage!.content;
  }
}

// Response wrapper for get-or-create conversation
class ConversationResponse {
  final int id;
  final String uuid;
  final List<ConversationParticipant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isNew;

  ConversationResponse({
    required this.id,
    required this.uuid,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isNew,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    
    return ConversationResponse(
      id: data['id'] as int,
      uuid: data['uuid'] as String,
      participants: (data['participants'] as List)
          .map((p) => ConversationParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastMessage: data['lastMessage'] != null
          ? Message.fromJson(data['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: data['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      isNew: meta['isNew'] as bool? ?? false,
    );
  }
}
