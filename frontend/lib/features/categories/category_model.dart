class Category {
  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.emoji,
    required this.color,
    required this.order,
  });

  final String id;
  final String name;
  final String type; // expense|income
  final String emoji;
  final String color;
  final int order;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    emoji: (json['emoji'] ?? '') as String,
    color: (json['color'] ?? '') as String,
    order: (json['order'] ?? 0) as int,
  );
}
