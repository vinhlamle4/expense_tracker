import '../../../../shared/exceptions/domain_exceptions.dart';
import '../../../../shared/models/transaction_filters.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/repositories/export_repository.dart';
import '../csv_export_service.dart';

class ExportRepositoryImpl implements ExportRepository {
  const ExportRepositoryImpl(this._transactionRepository, this._csvService);

  final TransactionRepository _transactionRepository;
  final CsvExportService _csvService;

  @override
  Future<String> exportToCsv({TransactionFilters? filters}) async {
    // Fetch ALL matching transactions (no pagination limit)
    final result = await _transactionRepository.getTransactions(
      filters: filters,
      page: 1,
      pageSize: 999999,
    );

    if (result.items.isEmpty) throw const EmptyExportException();

    return _csvService.writeToFile(result.items);
  }
}
