import 'package:expense_tracker/features/transactions/domain/entities/transaction_input.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/create_transaction.dart';
import 'package:expense_tracker/shared/exceptions/domain_exceptions.dart';
import 'package:expense_tracker/shared/models/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository repository;
  late CreateTransaction sut;

  setUpAll(() {
    registerFallbackValue(inputStub());
  });

  setUp(() {
    repository = MockTransactionRepository();
    sut = CreateTransaction(repository);
  });

  TransactionInput validInput({
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

  group('validateTransactionInput', () {
    test('throws ValidationException when amount is 0', () {
      expect(
        () => validateTransactionInput(validInput(amount: 0)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when amount is negative', () {
      expect(
        () => validateTransactionInput(validInput(amount: -500)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when date is empty', () {
      expect(
        () => validateTransactionInput(validInput(date: '')),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when date is invalid format', () {
      expect(
        () => validateTransactionInput(validInput(date: 'not-a-date')),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when date is before 1970', () {
      expect(
        () => validateTransactionInput(validInput(date: '1969-12-31')),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when note exceeds 500 chars', () {
      expect(
        () => validateTransactionInput(validInput(note: 'a' * 501)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('does not throw for valid input', () {
      expect(
        () => validateTransactionInput(validInput()),
        returnsNormally,
      );
    });

    test('does not throw when note is exactly 500 chars', () {
      expect(
        () => validateTransactionInput(validInput(note: 'a' * 500)),
        returnsNormally,
      );
    });
  });

  group('CreateTransaction.call', () {
    test('happy path — calls repository and returns transaction', () async {
      final input = validInput();
      final fakeTransaction = transactionStub(id: 1, amount: 10000);
      when(() => repository.createTransaction(input))
          .thenAnswer((_) async => fakeTransaction);

      final result = await sut.call(input);

      expect(result, equals(fakeTransaction));
      verify(() => repository.createTransaction(input)).called(1);
    });

    test('does not call repository for invalid input', () async {
      final input = validInput(amount: 0);

      await expectLater(
        () => sut.call(input),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => repository.createTransaction(any()));
    });
  });
}
