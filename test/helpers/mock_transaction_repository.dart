import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_input.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/shared/models/paginated_result.dart';
import 'package:expense_tracker/shared/models/transaction_type.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

Transaction transactionStub({
  int id = 1,
  int amount = 10000,
  TransactionType type = TransactionType.expense,
  int categoryId = 1,
  String categoryName = 'Food',
  String date = '2024-01-15',
  String? note,
}) =>
    Transaction(
      id: id,
      amount: amount,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
      date: date,
      note: note,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

TransactionInput inputStub({
  int amount = 10000,
  TransactionType type = TransactionType.expense,
  int categoryId = 1,
  String date = '2024-01-15',
  String? note,
}) =>
    TransactionInput(
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note,
    );

PaginatedResult<Transaction> paginatedStub({
  List<Transaction>? items,
  int totalCount = 1,
  int page = 1,
  int pageSize = 20,
}) =>
    PaginatedResult<Transaction>(
      items: items ?? [transactionStub()],
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
