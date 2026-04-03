import '../../../../shared/models/paginated_result.dart';
import '../../../../shared/models/transaction_filters.dart';
import '../entities/transaction.dart';
import '../entities/transaction_input.dart';

/// Domain-layer contract for transaction persistence.
/// Implementations live in the data layer only.
abstract class TransactionRepository {
  /// Returns a paginated list of transactions matching [filters], sorted by
  /// date descending then created_at descending.
  /// [page] is 1-indexed. [pageSize] defaults to 50.
  Future<PaginatedResult<Transaction>> getTransactions({
    TransactionFilters? filters,
    int page = 1,
    int pageSize = 50,
  });

  /// Returns the total count of transactions matching [filters].
  Future<int> countTransactions({TransactionFilters? filters});

  /// Creates a new transaction. Returns the persisted entity with assigned id.
  Future<Transaction> createTransaction(TransactionInput input);

  /// Updates the transaction identified by [id]. Returns the updated entity.
  /// Throws [TransactionNotFoundException] if no transaction exists for [id].
  Future<Transaction> updateTransaction(int id, TransactionInput input);

  /// Deletes the transaction with [id].
  /// Throws [TransactionNotFoundException] if no transaction exists for [id].
  Future<void> deleteTransaction(int id);
}
