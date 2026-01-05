class UserSearchResult {
  final int id;
  final String uuid;
  final String username;
  final String name;
  final String? fotoProfil;
  final String? email;
  final String? bio;

  UserSearchResult({
    required this.id,
    required this.uuid,
    required this.username,
    required this.name,
    this.fotoProfil,
    this.email,
    this.bio,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      fotoProfil: json['fotoProfil'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'username': username,
      'name': name,
      'fotoProfil': fotoProfil,
      'email': email,
      'bio': bio,
    };
  }

  String? getFullPhotoUrl(String baseUrl) {
    if (fotoProfil == null || fotoProfil!.isEmpty) return null;
    return '$baseUrl$fotoProfil';
  }
}
