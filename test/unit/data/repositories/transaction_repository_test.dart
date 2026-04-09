import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/fixtures.dart';
import '../../../fixtures/mocks.dart';

void main() {
  late FakeTransactionRepository repo;

  setUp(() {
    repo = FakeTransactionRepository();
  });

  tearDown(() {
    repo.dispose();
  });

  // ════════════════════════════════════════════════════════════════════════
  // Happy Paths
  // ════════════════════════════════════════════════════════════════════════

  group('getAll()', () {
    test('returns empty list when no transactions exist', () async {
      final result = await repo.getAll();
      expect(result, isEmpty);
    });

    test('returns all seeded transactions', () async {
      repo.setData([
        makeTransaction(id: 1, note: 'Coffee'),
        makeTransaction(id: 2, note: 'Taxi'),
      ]);

      final result = await repo.getAll();
      expect(result.length, 2);
      expect(result.map((t) => t.note), containsAll(['Coffee', 'Taxi']));
    });
  });

  group('add()', () {
    test('adds a transaction and it appears in getAll', () async {
      final t = makeTransaction(id: 1, note: 'Lunch');
      await repo.add(t);

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.note, 'Lunch');
    });

    test('adds multiple transactions independently', () async {
      await repo.add(makeTransaction(id: 1, note: 'A'));
      await repo.add(makeTransaction(id: 2, note: 'B'));
      await repo.add(makeTransaction(id: 3, note: 'C'));

      final all = await repo.getAll();
      expect(all.length, 3);
    });
  });

  group('update()', () {
    test('updates amount of existing transaction', () async {
      final original = makeTransaction(id: 1, amount: 100000, note: 'Before');
      await repo.add(original);

      final updated = makeTransaction(id: 1, amount: 200000, note: 'After');
      await repo.update(updated);

      final all = await repo.getAll();
      expect(all.first.amount, 200000);
      expect(all.first.note, 'After');
    });

    test('update with non-existent id does not add new record', () async {
      await repo.add(makeTransaction(id: 1, note: 'A'));
      await repo.update(makeTransaction(id: 99, note: 'Ghost'));

      // id 99 didn't exist; no new record should be inserted
      final all = await repo.getAll();
      expect(all.length, 1);
    });
  });

  group('delete()', () {
    test('removes transaction by id', () async {
      await repo.add(makeTransaction(id: 1, note: 'Keep'));
      await repo.add(makeTransaction(id: 2, note: 'Delete me'));

      await repo.delete(2);

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.note, 'Keep');
    });

    test('deleting non-existent id is a no-op', () async {
      await repo.add(makeTransaction(id: 1, note: 'A'));
      await repo.delete(999); // does not exist

      final all = await repo.getAll();
      expect(all.length, 1);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // watchAll() Stream
  // ════════════════════════════════════════════════════════════════════════

  group('watchAll()', () {
    test('emits current list on subscription', () async {
      repo.setData([makeTransaction(id: 1, note: 'A')]);

      final firstEmit = await repo.watchAll().first;
      expect(firstEmit.length, 1);
      expect(firstEmit.first.note, 'A');
    });

    test('emits updated list after add', () async {
      repo.setData([makeTransaction(id: 1, note: 'A')]);

      final emissions = <int>[];
      final sub = repo.watchAll().listen((list) => emissions.add(list.length));

      // Let the initial emit fire
      await Future.delayed(Duration(milliseconds: 10));

      await repo.add(makeTransaction(id: 2, note: 'B'));
      await Future.delayed(Duration(milliseconds: 10));

      expect(emissions.last, 2);
      await sub.cancel();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // reassignCategory (Bulk)
  // ════════════════════════════════════════════════════════════════════════

  group('reassignCategory()', () {
    test('reassigns all matching transactions to new category', () async {
      repo.setData([
        makeTransaction(id: 1, categoryId: 'food'),
        makeTransaction(id: 2, categoryId: 'food'),
        makeTransaction(id: 3, categoryId: 'transport'),
      ]);

      await repo.reassignCategory('food', 'uncategorized');

      final all = await repo.getAll();
      final foodTxs = all.where((t) => t.categoryId == 'food');
      final uncatTxs = all.where((t) => t.categoryId == 'uncategorized');

      expect(foodTxs, isEmpty);
      expect(uncatTxs.length, 2);
    });

    test('leaves unmatched transactions untouched', () async {
      repo.setData([
        makeTransaction(id: 1, categoryId: 'transport'),
        makeTransaction(id: 2, categoryId: 'salary'),
      ]);

      await repo.reassignCategory('food', 'uncategorized');

      final all = await repo.getAll();
      expect(all.every((t) => t.categoryId != 'uncategorized'), isTrue);
    });

    test('reassigning non-existent category is a no-op', () async {
      repo.setData([makeTransaction(id: 1, categoryId: 'food')]);

      await repo.reassignCategory('ghost', 'uncategorized');

      final all = await repo.getAll();
      expect(all.first.categoryId, 'food');
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Edge Cases & Boundaries
  // ════════════════════════════════════════════════════════════════════════

  group('edge cases', () {
    test('handles 1000+ transactions without error', () async {
      final many = makeManyTransactions(1100);
      repo.setData(many);

      final all = await repo.getAll();
      expect(all.length, 1100);
    });

    test('reassignCategory handles 500 matching transactions', () async {
      repo.setData(makeManyTransactions(500)
          .map((t) => makeTransaction(id: t.id, categoryId: 'old_cat'))
          .toList());

      await repo.reassignCategory('old_cat', 'uncategorized');

      final all = await repo.getAll();
      expect(all.every((t) => t.categoryId == 'uncategorized'), isTrue);
    });

    test('supports transactions with very large amounts (boundary)', () async {
      final t = makeTransaction(id: 1, amount: 999_999_999_999.0);
      await repo.add(t);

      final all = await repo.getAll();
      expect(all.first.amount, 999_999_999_999.0);
    });

    test('supports smallest positive amount (boundary)', () async {
      final t = makeTransaction(id: 1, amount: 0.01);
      await repo.add(t);

      final all = await repo.getAll();
      expect(all.first.amount, closeTo(0.01, 0.001));
    });
  });
}

