import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/data/models/category_model.dart';

import '../../../fixtures/fixtures.dart';
import '../../../fixtures/mocks.dart';

void main() {
  late FakeCategoryRepository catRepo;
  late FakeTransactionRepository txRepo;

  setUp(() {
    catRepo = FakeCategoryRepository();
    txRepo = FakeTransactionRepository();
  });

  tearDown(() {
    catRepo.dispose();
    txRepo.dispose();
  });

  // ════════════════════════════════════════════════════════════════════════
  // seedDefaults()
  // ════════════════════════════════════════════════════════════════════════

  group('seedDefaults()', () {
    test('seeds 11 default categories on first call', () async {
      await catRepo.seedDefaults();

      final all = await catRepo.getAll();
      expect(all.length, 11);
    });

    test('is idempotent: calling twice keeps only 11 categories', () async {
      await catRepo.seedDefaults();
      await catRepo.seedDefaults(); // second call must be a no-op

      final all = await catRepo.getAll();
      expect(all.length, 11);
    });

    test('contains uncategorized as default', () async {
      await catRepo.seedDefaults();

      final uncategorized = await catRepo.getById('uncategorized');
      expect(uncategorized, isNotNull);
      expect(uncategorized!.isDefault, isTrue);
    });

    test('contains food category after seeding', () async {
      await catRepo.seedDefaults();

      final food = await catRepo.getById('food');
      expect(food, isNotNull);
      expect(food!.name, 'Food & Drink');
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // getAll() and watchAll()
  // ════════════════════════════════════════════════════════════════════════

  group('getAll()', () {
    test('returns empty list before seeding', () async {
      final all = await catRepo.getAll();
      expect(all, isEmpty);
    });

    test('returns all categories after seeding', () async {
      await catRepo.seedDefaults();
      final all = await catRepo.getAll();
      expect(all.length, greaterThanOrEqualTo(11));
    });
  });

  group('watchAll()', () {
    test('emits current category list on subscription', () async {
      catRepo.setData(makeDefaultCategories());
      final firstEmit = await catRepo.watchAll().first;
      expect(firstEmit.length, 11);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // getById()
  // ════════════════════════════════════════════════════════════════════════

  group('getById()', () {
    test('returns category when it exists', () async {
      catRepo.setData(makeDefaultCategories());

      final result = await catRepo.getById('transport');
      expect(result, isNotNull);
      expect(result!.name, 'Transport');
    });

    test('returns null for unknown id', () async {
      catRepo.setData(makeDefaultCategories());

      final result = await catRepo.getById('nonexistent_id');
      expect(result, isNull);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // add()
  // ════════════════════════════════════════════════════════════════════════

  group('add()', () {
    test('adds a custom category', () async {
      final custom = CategoryModelFactory.custom(id: 'freelance', name: 'Freelance');
      await catRepo.add(custom);

      final result = await catRepo.getById('freelance');
      expect(result, isNotNull);
      expect(result!.name, 'Freelance');
    });

    test('adding duplicate id replaces existing category (upsert)', () async {
      catRepo.setData([makeCategory(id: 'food', name: 'Food & Drink')]);

      final updated = makeCategory(id: 'food', name: 'Food Updated');
      await catRepo.add(updated);

      final all = await catRepo.getAll();
      final food = all.where((c) => c.id == 'food').toList();
      expect(food.length, 1);
      expect(food.first.name, 'Food Updated');
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // delete()
  // ════════════════════════════════════════════════════════════════════════

  group('delete()', () {
    test('removes category by id', () async {
      catRepo.setData(makeDefaultCategories());

      await catRepo.delete('food');

      final result = await catRepo.getById('food');
      expect(result, isNull);
    });

    test('deleting non-existent id is a no-op', () async {
      catRepo.setData(makeDefaultCategories());

      await catRepo.delete('ghost_id');

      final all = await catRepo.getAll();
      expect(all.length, 11); // unchanged
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // deleteAndReassign()
  // ════════════════════════════════════════════════════════════════════════

  group('deleteAndReassign()', () {
    test('moves all transactions to uncategorized then removes category', () async {
      catRepo.setData(makeDefaultCategories());
      txRepo.setData([
        makeTransaction(id: 1, categoryId: 'food'),
        makeTransaction(id: 2, categoryId: 'food'),
        makeTransaction(id: 3, categoryId: 'transport'),
      ]);

      await catRepo.deleteAndReassign('food', txRepo);

      // Category removed
      expect(await catRepo.getById('food'), isNull);

      // Transactions reassigned
      final transactions = await txRepo.getAll();
      final movedToUncat =
          transactions.where((t) => t.categoryId == 'uncategorized').length;
      expect(movedToUncat, 2);
      expect(transactions.firstWhere((t) => t.id == 3).categoryId, 'transport');
    });

    test('deleteAndReassign with no matching transactions only deletes category', () async {
      catRepo.setData(makeDefaultCategories());
      txRepo.setData([makeTransaction(id: 1, categoryId: 'transport')]);

      await catRepo.deleteAndReassign('food', txRepo);

      expect(await catRepo.getById('food'), isNull);

      // No transactions should be changed
      final transactions = await txRepo.getAll();
      expect(transactions.first.categoryId, 'transport');
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Edge cases
  // ════════════════════════════════════════════════════════════════════════

  group('edge cases', () {
    test('does not seed when data is already present', () async {
      catRepo.setData([makeCategory(id: 'custom', name: 'Custom')]);
      // Direct setData bypasses the _seeded flag; calling seedDefaults should not
      // overwrite since _seeded is checked from the repo flag internal logic.
      // Verify: after setData, we have 1 category; calling seedDefaults with
      // the existing data > 0 means no seeding happens.
      await catRepo.seedDefaults(); // _seeded is false but _data is non-empty

      // Our FakeCategoryRepository only seeds when _data is empty AND _seeded is false
      final all = await catRepo.getAll();
      // Still just the 1 custom category — seeding was skipped
      expect(all.length, 1);
    });
  });
}



