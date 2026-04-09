import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    // ── Happy paths ────────────────────────────────────────────────────────

    test('creates expense transaction with all required fields', () {
      final t = TransactionModel()
        ..amount = 150000
        ..date = DateTime(2026, 4, 6)
        ..categoryId = 'food'
        ..note = 'Coffee'
        ..isIncome = false;

      expect(t.amount, 150000);
      expect(t.date, DateTime(2026, 4, 6));
      expect(t.categoryId, 'food');
      expect(t.note, 'Coffee');
      expect(t.isIncome, false);
    });

    test('creates income transaction', () {
      final t = TransactionModel()
        ..amount = 10000000
        ..date = DateTime(2026, 4, 1)
        ..categoryId = 'salary'
        ..note = 'Monthly salary'
        ..isIncome = true;

      expect(t.isIncome, true);
      expect(t.amount, 10000000);
      expect(t.categoryId, 'salary');
    });

    test('note is empty string by default', () {
      final t = TransactionModel()
        ..amount = 50000
        ..date = DateTime(2026, 4, 6)
        ..categoryId = 'food'
        ..isIncome = false;

      expect(t.note, '');
    });

    // ── Edge cases & boundaries ─────────────────────────────────────────────

    test('id is Isar.autoIncrement by default', () {
      final t = TransactionModel();
      expect(t.id, Isar.autoIncrement);
    });

    test('supports very large amounts (boundary)', () {
      final t = TransactionModel()
        ..amount = 999999999999.0
        ..date = DateTime(2026, 1, 1)
        ..categoryId = 'salary'
        ..isIncome = true;

      expect(t.amount, 999999999999.0);
    });

    test('supports smallest positive amount (boundary)', () {
      final t = TransactionModel()
        ..amount = 0.01
        ..date = DateTime(2026, 4, 6)
        ..categoryId = 'food'
        ..isIncome = false;

      expect(t.amount, closeTo(0.01, 0.001));
    });

    test('supports date at year boundary (Dec 31 → Jan 1)', () {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);

      final t1 = TransactionModel()
        ..amount = 100
        ..date = dec31
        ..categoryId = 'food'
        ..isIncome = false;
      final t2 = TransactionModel()
        ..amount = 100
        ..date = jan1
        ..categoryId = 'food'
        ..isIncome = false;

      expect(t1.date.year, 2025);
      expect(t2.date.year, 2026);
    });

    test('can reassign categoryId after construction', () {
      final t = TransactionModel()
        ..amount = 100
        ..date = DateTime(2026, 4, 6)
        ..categoryId = 'food'
        ..isIncome = false;

      t.categoryId = 'uncategorized';
      expect(t.categoryId, 'uncategorized');
    });
  });
}

