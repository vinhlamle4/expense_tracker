import '../../domain/entities/category.dart';

class CategoryModel {
  const CategoryModel._();

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colour: map['colour'] as String,
      isSystem: (map['is_system'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  static Map<String, dynamic> toInsertMap(
      {required String name,
      required String icon,
      required String colour,
      bool isSystem = false}) {
    return {
      'name': name,
      'icon': icon,
      'colour': colour,
      'is_system': isSystem ? 1 : 0,
    };
  }

  static Map<String, dynamic> toUpdateMap({
    required String name,
    required String icon,
    required String colour,
  }) {
    return {
      'name': name,
      'icon': icon,
      'colour': colour,
    };
  }
}
