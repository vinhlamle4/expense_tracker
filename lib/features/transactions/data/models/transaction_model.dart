import '../../../../shared/models/transaction_type.dart';
import '../../domain/entities/transaction.dart';

/// Converts between SQLite row maps and the domain [Transaction] entity.
/// The map is expected to contain JOIN columns from categories:
/// category_name, icon (as cat_icon), colour (as cat_colour).
class TransactionModel {
  const TransactionModel._();

  static Transaction fromMap(Map<String, Object?> map) => Transaction(
        id: map['id'] as int,
        amount: map['amount'] as int,
        type: TransactionType.fromString(map['type'] as String),
        categoryId: map['category_id'] as int,
        categoryName: (map['category_name'] as String?) ?? 'Uncategorized',
        categoryIcon: map['cat_icon'] as String?,
        categoryColour: map['cat_colour'] as String?,
        date: map['date'] as String,
        note: map['note'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  static Map<String, Object?> toMap(Transaction t) => {
        'amount': t.amount,
        'type': t.type.value,
        'category_id': t.categoryId,
        'date': t.date,
        'note': t.note,
        'created_at': t.createdAt.toIso8601String(),
        'updated_at': t.updatedAt.toIso8601String(),
      };

  /// Map used for INSERT (no id).
  static Map<String, Object?> insertMap({
    required int amount,
    required String type,
    required int categoryId,
    required String date,
    String? note,
    required String now,
  }) =>
      {
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'date': date,
        'note': note,
        'created_at': now,
        'updated_at': now,
      };

  /// Map used for UPDATE (excludes id and created_at).
  static Map<String, Object?> updateMap({
    required int amount,
    required String type,
    required int categoryId,
    required String date,
    String? note,
    required String now,
  }) =>
      {
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'date': date,
        'note': note,
        'updated_at': now,
      };
}
