import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id get isarId => fastHash(id);

  late String id; // UUID / slug — human-readable PK

  late String name;

  late String icon; // Material Icons code point as hex string e.g. 'e56c'

  late int colorValue; // ARGB int for chip/icon tint

  /// Whether this category is pre-seeded (cannot be deleted by user).
  bool isDefault = false;
}

/// Deterministic Isar integer id derived from the string [id] field.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

/// Factory helpers for creating [CategoryModel] instances.
abstract final class CategoryModelFactory {
  /// Creates a custom (user-defined) category with sensible defaults.
  static CategoryModel custom({
    required String id,
    required String name,
    String icon = 'e8b8', // Icons.label
    int colorValue = 0xFF9E9E9E, // Colors.grey
  }) =>
      CategoryModel()
        ..id = id
        ..name = name
        ..icon = icon
        ..colorValue = colorValue
        ..isDefault = false;
}

