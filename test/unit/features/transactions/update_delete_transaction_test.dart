import 'package:expense_tracker/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/update_transaction.dart';
import 'package:expense_tracker/shared/exceptions/domain_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository repository;

  setUp(() {
    repository = MockTransactionRepository();
    registerFallbackValue(inputStub());
  });

  group('UpdateTransaction', () {
    late UpdateTransaction sut;

    setUp(() => sut = UpdateTransaction(repository));

    test('happy path — validates and delegates to repository', () async {
      final input = inputStub(amount: 20000);
      final updated = transactionStub(id: 42, amount: 20000);
      when(() => repository.updateTransaction(42, input))
          .thenAnswer((_) async => updated);

      final result = await sut.call(42, input);

      expect(result, equals(updated));
      verify(() => repository.updateTransaction(42, input)).called(1);
    });

    test('throws ValidationException and skips repository for invalid amount',
        () async {
      final bad = inputStub(amount: 0);

      await expectLater(
        () => sut.call(1, bad),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => repository.updateTransaction(any(), any()));
    });
  });

  group('DeleteTransaction', () {
    late DeleteTransaction sut;

    setUp(() => sut = DeleteTransaction(repository));

    test('delegates to repository', () async {
      when(() => repository.deleteTransaction(5)).thenAnswer((_) async {});

      await sut.call(5);

      verify(() => repository.deleteTransaction(5)).called(1);
    });

    test('propagates TransactionNotFoundException', () async {
      when(() => repository.deleteTransaction(99))
          .thenThrow(const TransactionNotFoundException(99));

      await expectLater(
        () => sut.call(99),
        throwsA(isA<TransactionNotFoundException>()),
      );
    });
  });
}
