import '../entities/transaction.dart';
import '../entities/transaction_input.dart';
import '../repositories/transaction_repository.dart';
import 'create_transaction.dart';

/// Validates and updates an existing transaction.
class UpdateTransaction {
  const UpdateTransaction(this._repository);
  final TransactionRepository _repository;

  Future<Transaction> call(int id, TransactionInput input) async {
    validateTransactionInput(input);
    return _repository.updateTransaction(id, input);
  }
}
