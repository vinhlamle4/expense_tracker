import '../../../../shared/exceptions/domain_exceptions.dart';
import '../entities/transaction.dart';
import '../entities/transaction_input.dart';
import '../repositories/transaction_repository.dart';

/// Validates a [TransactionInput]; throws [ValidationException] on failure.
/// Used by both [CreateTransaction] and [UpdateTransaction].
void validateTransactionInput(TransactionInput input) {
  if (input.amount <= 0) {
    throw const ValidationException('amount', 'Amount must be greater than 0');
  }
  if (input.date.isEmpty) {
    throw const ValidationException('date', 'Date is required');
  }
  if (!_isValidDate(input.date)) {
    throw const ValidationException('date', 'Please enter a valid date');
  }
  if (input.note != null && input.note!.length > 500) {
    throw const ValidationException('note', 'Note cannot exceed 500 characters');
  }
}

bool _isValidDate(String date) {
  try {
    final d = DateTime.parse(date);
    return !d.isBefore(DateTime(1970));
  } catch (_) {
    return false;
  }
}

/// Validates and creates a new transaction.
class CreateTransaction {
  const CreateTransaction(this._repository);
  final TransactionRepository _repository;

  Future<Transaction> call(TransactionInput input) async {
    validateTransactionInput(input);
    return _repository.createTransaction(input);
  }
}
