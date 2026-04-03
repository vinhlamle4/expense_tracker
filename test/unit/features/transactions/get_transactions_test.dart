import 'package:expense_tracker/features/transactions/domain/usecases/get_transactions.dart';
import 'package:expense_tracker/shared/models/paginated_result.dart';
import 'package:expense_tracker/shared/models/transaction_filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository repository;
  late GetTransactions sut;

  setUpAll(() {
    registerFallbackValue(const TransactionFilters());
  });

  setUp(() {
    repository = MockTransactionRepository();
    sut = GetTransactions(repository);
  });

  test('returns paginated result with default page and pageSize', () async {
    final expected = paginatedStub();
    when(() => repository.getTransactions(
          filters: any(named: 'filters'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => expected);

    final result = await sut.call();

    expect(result, equals(expected));
    verify(() => repository.getTransactions(
          filters: any(named: 'filters'),
          page: 1,
          pageSize: 50,
        )).called(1);
  });

  test('passes explicit page and pageSize to repository', () async {
    final expected = paginatedStub(page: 2, pageSize: 10, totalCount: 25);
    when(() => repository.getTransactions(
          filters: any(named: 'filters'),
          page: 2,
          pageSize: 10,
        )).thenAnswer((_) async => expected);

    final result = await sut.call(page: 2, pageSize: 10);

    expect(result.page, 2);
    expect(result.pageSize, 10);
    verify(() => repository.getTransactions(
          filters: any(named: 'filters'),
          page: 2,
          pageSize: 10,
        )).called(1);
  });

  test('PaginatedResult.hasMore is true when more pages exist', () {
    final r = paginatedStub(totalCount: 30, page: 1, pageSize: 20);
    expect(r.hasMore, isTrue);
  });

  test('PaginatedResult.hasMore is false on last page', () {
    final r = paginatedStub(totalCount: 15, page: 1, pageSize: 20);
    expect(r.hasMore, isFalse);
  });

  test('PaginatedResult.isEmpty is true when no items', () {
    const r = PaginatedResult<dynamic>(
        items: [], totalCount: 0, page: 1, pageSize: 20);
    expect(r.isEmpty, isTrue);
  });
}
