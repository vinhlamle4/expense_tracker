import '../../../../shared/models/paginated_result.dart';
import '../../../../shared/models/transaction_filters.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Retrieves a paginated, optionally filtered list of transactions.
class GetTransactions {
  const GetTransactions(this._repository);
  final TransactionRepository _repository;

  Future<PaginatedResult<Transaction>> call({
    TransactionFilters? filters,
    int page = 1,
    int pageSize = 50,
  }) =>
      _repository.getTransactions(
        filters: filters,
        page: page,
        pageSize: pageSize,
      );
}
