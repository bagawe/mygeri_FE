class BlockUser {
  final int id;
  final int blockerId;
  final int blockedUserId;
  final String? blockedAt;
  final String? username;
  final String? name;
  final String? fotoProfil;

  BlockUser({
    required this.id,
    required this.blockerId,
    required this.blockedUserId,
    this.blockedAt,
    this.username,
    this.name,
    this.fotoProfil,
  });

  factory BlockUser.fromJson(Map<String, dynamic> json) {
    return BlockUser(
      id: json['id'], // This is the user ID (blocked user)
      blockerId: json['blockerId'] ?? json['blocker_id'] ?? 0,
      blockedUserId: json['blockedUserId'] ?? json['blocked_user_id'] ?? json['id'], // Use 'id' as blockedUserId
      blockedAt: json['blockedAt'],
      username: json['username'],
      name: json['name'],
      fotoProfil: json['fotoProfil'],
    );
  }
}
