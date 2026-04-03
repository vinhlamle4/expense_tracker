import '../../../../shared/exceptions/domain_exceptions.dart';
import '../../../../shared/models/transaction_filters.dart';
import '../repositories/export_repository.dart';

class ExportToCsv {
  const ExportToCsv(this._repository);

  final ExportRepository _repository;

  /// Exports matching transactions to a CSV file.
  /// Throws [EmptyExportException] if no transactions match [filters].
  Future<String> call({TransactionFilters? filters}) async {
    final path = await _repository.exportToCsv(filters: filters);
    return path;
  }
}
