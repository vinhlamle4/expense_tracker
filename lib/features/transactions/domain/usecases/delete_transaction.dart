import '../repositories/transaction_repository.dart';

/// Deletes a transaction by id.
class DeleteTransaction {
  const DeleteTransaction(this._repository);
  final TransactionRepository _repository;

  Future<void> call(int id) => _repository.deleteTransaction(id);
}
