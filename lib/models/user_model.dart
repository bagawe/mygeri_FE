class UserModel {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String username;
  final bool isActive;
  final String? phone;
  final String? bio;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.username,
    required this.isActive,
    this.phone,
    this.bio,
    this.location,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Debug: Print JSON untuk troubleshooting
    print('=== USER MODEL FROM JSON ===');
    print('JSON received: $json');
    
    return UserModel(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'email': email,
      'username': username,
      'isActive': isActive,
      'phone': phone,
      'bio': bio,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
