class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colour,
    required this.isSystem,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String icon;
  final String colour;
  final bool isSystem;
  final String createdAt;

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? colour,
    bool? isSystem,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colour: colour ?? this.colour,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
