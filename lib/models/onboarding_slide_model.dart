/// Model untuk OnboardingSlide dari API backend
class OnboardingSlideModel {
  final int id;
  final String uuid;
  final int order;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? backgroundColor;
  final String type;
  final bool skipAllowed;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OnboardingSlideModel({
    required this.id,
    required this.uuid,
    required this.order,
    this.title,
    this.description,
    this.imageUrl,
    this.backgroundColor,
    required this.type,
    required this.skipAllowed,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor untuk parse dari JSON
  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) {
    return OnboardingSlideModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      order: json['order'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      type: json['type'] as String,
      skipAllowed: json['skipAllowed'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert ke JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'order': order,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'backgroundColor': backgroundColor,
    'type': type,
    'skipAllowed': skipAllowed,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() => 'OnboardingSlide(id: $id, order: $order, type: $type, title: $title)';
}
