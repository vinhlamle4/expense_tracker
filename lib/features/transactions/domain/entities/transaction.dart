import '../../../../shared/models/transaction_type.dart';

/// Pure Dart domain entity — no Flutter, no sqflite imports.
class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColour,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;

  /// Monetary amount in minor currency units (e.g., VND whole đồng).
  /// Always > 0.
  final int amount;

  final TransactionType type;

  final int categoryId;

  /// Denormalized from JOIN — display only, not stored on this entity.
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColour;

  /// User-entered date in YYYY-MM-DD format.
  final String date;

  final String? note;

  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction copyWith({
    int? amount,
    TransactionType? type,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColour,
    String? date,
    String? note,
    DateTime? updatedAt,
  }) =>
      Transaction(
        id: id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        categoryIcon: categoryIcon ?? this.categoryIcon,
        categoryColour: categoryColour ?? this.categoryColour,
        date: date ?? this.date,
        note: note ?? this.note,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
