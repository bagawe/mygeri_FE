class UserRole {
  final int id;
  final String uuid;
  final int userId;
  final String role;

  UserRole({
    required this.id,
    required this.uuid,
    required this.userId,
    required this.role,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
      role: json['role'] as String? ?? 'simpatisan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'userId': userId,
      'role': role,
    };
  }
}
