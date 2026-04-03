import '../../../../shared/models/transaction_filters.dart';

abstract interface class ExportRepository {
  /// Exports all transactions matching [filters] to a CSV file.
  /// Returns the absolute path to the written file.
  /// Throws [EmptyExportException] if no transactions match.
  Future<String> exportToCsv({TransactionFilters? filters});
}
