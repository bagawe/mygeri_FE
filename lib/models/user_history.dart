class UserHistory {
  final int id;
  final String type;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  UserHistory({
    required this.id,
    required this.type,
    this.description,
    this.metadata,
    required this.createdAt,
  });

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    return UserHistory(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
