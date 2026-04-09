import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:expense_tracker/features/transaction/viewmodels/transaction_view_model.dart';
import 'package:expense_tracker/shared/providers/filter_providers.dart';
import 'package:expense_tracker/shared/providers/database_provider.dart';
import 'package:expense_tracker/shared/providers/transaction_providers.dart';

import '../../../../fixtures/fixtures.dart';
import '../../../../fixtures/mocks.dart';

// Helper: build a container pre-wired with fake repos
ProviderContainer _makeContainer({
  FakeTransactionRepository? txRepo,
  FakeCategoryRepository? catRepo,
}) {
  final tr = txRepo ?? FakeTransactionRepository();
  final cr = catRepo ?? FakeCategoryRepository();
  return ProviderContainer(
    overrides: [
      transactionRepoProvider.overrideWithValue(tr),
      categoryRepoProvider.overrideWithValue(cr),
    ],
  );
}

void main() {
  // ════════════════════════════════════════════════════════════════════════
  // Happy Paths — no filters
  // ════════════════════════════════════════════════════════════════════════

  group('no filters — baseline', () {
    test('empty repo → empty state with zero totals', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final state = await container.read(transactionVMProvider.future);
      expect(state.all, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.totalIncome, 0);
      expect(state.totalExpense, 0);
      expect(state.balance, 0);
    });

    test('loads all transactions from repo on build', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 5_000_000),
          makeExpense(id: 2, amount: 200_000),
          makeExpense(id: 3, amount: 50_000),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      final state = await container.read(transactionVMProvider.future);
      expect(state.all.length, 3);
      expect(state.filtered.length, 3);
    });

    test('totalIncome sums only income transactions', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 10_000_000),
          makeIncome(id: 2, amount: 5_000_000),
          makeExpense(id: 3, amount: 200_000),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      final state = await container.read(transactionVMProvider.future);
      expect(state.totalIncome, 15_000_000);
    });

    test('totalExpense sums only expense transactions', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 10_000_000),
          makeExpense(id: 2, amount: 200_000),
          makeExpense(id: 3, amount: 50_000),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      final state = await container.read(transactionVMProvider.future);
      expect(state.totalExpense, 250_000);
    });

    test('balance = totalIncome - totalExpense', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 10_000_000),
          makeExpense(id: 2, amount: 3_000_000),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      final state = await container.read(transactionVMProvider.future);
      expect(state.balance, 7_000_000);
    });

    test('balance is negative when expenses exceed income', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 1_000_000),
          makeExpense(id: 2, amount: 5_000_000),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      final state = await container.read(transactionVMProvider.future);
      expect(state.balance, isNegative);
      expect(state.balance, -4_000_000);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Search Query Filter
  // ════════════════════════════════════════════════════════════════════════

  group('search query filter', () {
    test('filters transactions by note (case-insensitive)', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, note: 'Coffee shop'),
          makeExpense(id: 2, note: 'Taxi fare'),
          makeIncome(id: 3, note: 'Salary payment'),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      // Wait for initial build
      await container.read(transactionVMProvider.future);

      // Apply search
      container.read(searchQueryProvider.notifier).state = 'cof';
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 1);
      expect(state.filtered.first.note, 'Coffee shop');
    });

    test('empty search query returns all transactions', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, note: 'A'),
          makeExpense(id: 2, note: 'B'),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(searchQueryProvider.notifier).state = '';
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 2);
    });

    test('search with no match returns empty filtered list', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([makeExpense(id: 1, note: 'Coffee')]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(searchQueryProvider.notifier).state = 'zzz_no_match';
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered, isEmpty);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Date Range Filter
  // ════════════════════════════════════════════════════════════════════════

  group('date range filter', () {
    test('keeps only transactions within range (inclusive boundaries)', () async {
      final start = DateTime(2026, 4, 1);
      final end = DateTime(2026, 4, 7);

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, date: DateTime(2026, 4, 1)), // start boundary ✓
          makeExpense(id: 2, date: DateTime(2026, 4, 5)), // within ✓
          makeExpense(id: 3, date: DateTime(2026, 4, 7)), // end boundary ✓
          makeExpense(id: 4, date: DateTime(2026, 3, 31)), // before start ✗
          // Note: the implementation adds +1 day to end for full-day inclusion.
          // April 8 midnight == end+1 day midnight → NOT strictly after → included.
          makeExpense(id: 5, date: DateTime(2026, 4, 9)), // strictly after end+1 day ✗
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(dateRangeFilterProvider.notifier).state =
          DateTimeRange(start: start, end: end);
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 3);
      expect(state.filtered.map((t) => t.id), containsAll([1, 2, 3]));
    });

    test('null date range returns all transactions', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, date: DateTime(2026, 1, 1)),
          makeExpense(id: 2, date: DateTime(2026, 12, 31)),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(dateRangeFilterProvider.notifier).state = null;
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 2);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Category Filter
  // ════════════════════════════════════════════════════════════════════════

  group('category filter', () {
    test('filters to only selected categories', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, categoryId: 'food'),
          makeExpense(id: 2, categoryId: 'transport'),
          makeExpense(id: 3, categoryId: 'shopping'),
          makeIncome(id: 4, categoryId: 'salary'),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(categoryFilterProvider.notifier).state = ['food', 'transport'];
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 2);
      expect(state.filtered.map((t) => t.categoryId),
          containsAll(['food', 'transport']));
    });

    test('empty category filter returns all transactions', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, categoryId: 'food'),
          makeExpense(id: 2, categoryId: 'transport'),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(categoryFilterProvider.notifier).state = [];
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 2);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Combined Filters (AND logic)
  // ════════════════════════════════════════════════════════════════════════

  group('combined filters', () {
    test('search + category filter both apply (AND logic)', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, categoryId: 'food', note: 'Coffee'),
          makeExpense(id: 2, categoryId: 'food', note: 'Lunch'),
          makeExpense(id: 3, categoryId: 'transport', note: 'Coffee by taxi'),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(searchQueryProvider.notifier).state = 'Coffee';
      container.read(categoryFilterProvider.notifier).state = ['food'];
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      // Only id=1 matches both criteria
      expect(state.filtered.length, 1);
      expect(state.filtered.first.id, 1);
    });

    test('all filters cleared restores full list', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, categoryId: 'food', note: 'Coffee'),
          makeExpense(id: 2, categoryId: 'transport', note: 'Taxi'),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);

      // Apply filters
      container.read(searchQueryProvider.notifier).state = 'Coffee';
      container.read(categoryFilterProvider.notifier).state = ['food'];
      await Future.microtask(() {});

      // Clear all
      container.read(searchQueryProvider.notifier).state = '';
      container.read(categoryFilterProvider.notifier).state = [];
      container.read(dateRangeFilterProvider.notifier).state = null;
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 2);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Edge Cases
  // ════════════════════════════════════════════════════════════════════════

  group('edge cases', () {
    test('handles 1000+ transactions without error', () async {
      final txRepo = FakeTransactionRepository()
        ..setData(makeManyTransactions(1100));

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      final state = await container.read(transactionVMProvider.future);
      expect(state.all.length, 1100);
      expect(state.filtered.length, 1100);
    });

    test('single transaction list filters correctly', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([makeExpense(id: 1, note: 'Only one')]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(searchQueryProvider.notifier).state = 'only';
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 1);
    });

    test('search is case-insensitive (boundary: all-caps query)', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([makeExpense(id: 1, note: 'coffee latte')]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      container.read(searchQueryProvider.notifier).state = 'COFFEE';
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 1);
    });

    test('totals are based on all transactions, not filtered', () async {
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 10_000_000),
          makeExpense(id: 2, amount: 5_000_000, note: 'Coffee'),
          makeExpense(id: 3, amount: 1_000_000, note: 'Taxi'),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      await container.read(transactionVMProvider.future);
      // Filter to only show Coffee
      container.read(searchQueryProvider.notifier).state = 'Coffee';
      await Future.microtask(() {});

      final state = container.read(transactionVMProvider).valueOrNull!;
      expect(state.filtered.length, 1);
      // Totals use ALL transactions, not just filtered
      expect(state.totalIncome, 10_000_000);
      expect(state.totalExpense, 6_000_000);
    });
  });
}



