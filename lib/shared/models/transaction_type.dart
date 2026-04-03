/// Classifies a transaction as income or expense.
/// Stored as a string ('income' / 'expense') in SQLite.
enum TransactionType {
  income,
  expense;

  String get value => name; // 'income' or 'expense'

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown TransactionType: $value'),
    );
  }
}
