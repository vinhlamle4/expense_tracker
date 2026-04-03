import '../../../../shared/models/transaction_type.dart';

/// Input DTO for creating or updating a transaction.
class TransactionInput {
  const TransactionInput({
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
  });

  /// Must be > 0, integer minor units.
  final int amount;

  final TransactionType type;
  final int categoryId;

  /// YYYY-MM-DD string.
  final String date;

  /// Optional free-text memo, max 500 chars.
  final String? note;
}
