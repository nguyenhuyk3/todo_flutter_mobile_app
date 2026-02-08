class TagModel {
  final String id;
  final String userId;
  final String name;
  final String color; // Hex, e.g. #EF4444

  const TagModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'name': name, 'color': color};
  }
}
