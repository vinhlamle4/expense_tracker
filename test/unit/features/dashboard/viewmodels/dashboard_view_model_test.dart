import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:expense_tracker/shared/providers/dashboard_providers.dart';
import 'package:expense_tracker/shared/providers/category_providers.dart';
import 'package:expense_tracker/shared/providers/database_provider.dart';
import 'package:expense_tracker/shared/providers/transaction_providers.dart';

import '../../../../fixtures/fixtures.dart';
import '../../../../fixtures/mocks.dart';

// Build a container that drives DashboardViewModel through fake repos.
// Overrides categoryListProvider directly so stream timing is deterministic.
ProviderContainer _makeContainer({
  FakeTransactionRepository? txRepo,
  List<dynamic>? categories,
}) {
  final tr = txRepo ?? FakeTransactionRepository();
  final cats = (categories?.cast<CategoryModel>() ?? makeDefaultCategories());
  final cr = FakeCategoryRepository()..setData(cats);
  return ProviderContainer(
    overrides: [
      transactionRepoProvider.overrideWithValue(tr),
      categoryRepoProvider.overrideWithValue(cr),
      categoryListProvider.overrideWith((ref) => Stream.value(cr.data)),
    ],
  );
}

void main() {
  // ════════════════════════════════════════════════════════════════════════
  // Empty State
  // ════════════════════════════════════════════════════════════════════════

  group('empty state', () {
    test('returns DashboardSummary.empty when no transactions exist', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);      // Wait for transactionVM to load
      await container.read(transactionVMProvider.future);
      await Future.microtask(() {});

      final summary = container.read(dashboardVMProvider);
      expect(summary.isEmpty, isTrue);
      expect(summary.totalIncome, 0);
      expect(summary.totalExpense, 0);
      expect(summary.balance, 0);
      expect(summary.categoryBreakdown, isEmpty);
    });

    test('empty state when no transactions match selected period', () async {
      final now = DateTime.now();
      // Put all transactions in a different month (next month)
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final txRepo = FakeTransactionRepository()
        ..setData([makeExpense(id: 1, date: nextMonth)]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.day;

      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.isEmpty, isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Period: Day
  // ════════════════════════════════════════════════════════════════════════

  group('period = DAY', () {
    test('includes only transactions from today', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, amount: 100_000, date: today),
          makeExpense(id: 2, amount: 200_000, date: yesterday),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.day;

      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.totalExpense, 100_000); // only today
    });

    test('ignores tomorrow transactions when period = DAY', () async {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      final txRepo = FakeTransactionRepository()
        ..setData([makeExpense(id: 1, amount: 500_000, date: tomorrow)]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.day;

      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.isEmpty, isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Period: Week
  // ════════════════════════════════════════════════════════════════════════

  group('period = WEEK', () {
    test('includes transactions from current week only', () async {
      final now = DateTime.now();
      // Start of current week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final monday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final lastMonday = monday.subtract(const Duration(days: 7));

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, amount: 100_000, date: monday), // this week ✓
          makeExpense(id: 2, amount: 200_000, date: lastMonday), // last week ✗
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.week;

      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.totalExpense, 100_000); // only this week
    });

    test('week spanning two months includes both months', () async {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final monday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final friday = monday.add(const Duration(days: 4));

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, amount: 100_000, date: monday),
          makeExpense(id: 2, amount: 200_000, date: friday),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.week;

      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.totalExpense, 300_000); // both days in same week
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Period: Month
  // ════════════════════════════════════════════════════════════════════════

  group('period = MONTH', () {
    test('includes only current month transactions', () async {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 10);
      final lastMonth = DateTime(now.year, now.month - 1, 10);

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, amount: 100_000, date: thisMonth), // ✓
          makeExpense(id: 2, amount: 200_000, date: lastMonth), // ✗
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.month;

      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.totalExpense, 100_000);
    });

    test('includes both income and expense in monthly totals', () async {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, 5);

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 10_000_000, date: date),
          makeExpense(id: 2, amount: 3_000_000, date: date),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.month;

      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.totalIncome, 10_000_000);
      expect(summary.totalExpense, 3_000_000);
      expect(summary.balance, 7_000_000);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Category Breakdown
  // ════════════════════════════════════════════════════════════════════════

  group('category breakdown', () {
    test('groups expenses by category and sorts descending', () async {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, 5);

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, amount: 200_000, categoryId: 'food', date: date),
          makeExpense(id: 2, amount: 500_000, categoryId: 'food', date: date),
          makeExpense(id: 3, amount: 300_000, categoryId: 'transport', date: date),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.month;

      await container.read(transactionVMProvider.future);
      await container.read(categoryListProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      expect(summary.categoryBreakdown.length, 2);
      // food = 700k, transport = 300k → sorted desc
      expect(summary.categoryBreakdown.first.amount, 700_000);
      expect(summary.categoryBreakdown.first.category.id, 'food');
      expect(summary.categoryBreakdown.last.amount, 300_000);
      expect(summary.categoryBreakdown.last.category.id, 'transport');
    });

    test('income transactions are excluded from category breakdown', () async {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, 5);

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeIncome(id: 1, amount: 5_000_000, categoryId: 'salary', date: date),
          makeExpense(id: 2, amount: 100_000, categoryId: 'food', date: date),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.month;

      await container.read(transactionVMProvider.future);
      await container.read(categoryListProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      // Only food should appear in breakdown (income excluded)
      expect(summary.categoryBreakdown.length, 1);
      expect(summary.categoryBreakdown.first.category.id, 'food');
    });

    test('missing category id is excluded from breakdown without crash', () async {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, 5);
      // Only 'food' category exists — 'ghost_cat' is missing from map
      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, amount: 100_000, categoryId: 'food', date: date),
          makeExpense(id: 2, amount: 999_000, categoryId: 'ghost_cat', date: date),
        ]);

      final container = _makeContainer(
        txRepo: txRepo,
        categories: [makeCategory(id: 'food', name: 'Food')],
      );
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.month;

      await container.read(transactionVMProvider.future);
      await container.read(categoryListProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final summary = container.read(dashboardVMProvider);
      // 'ghost_cat' not in categoryMap → filtered out
      expect(summary.categoryBreakdown.length, 1);
      expect(summary.categoryBreakdown.first.category.id, 'food');
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Period Switching
  // ════════════════════════════════════════════════════════════════════════

  group('period switching', () {
    test('summary updates when period changes', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastMonth = DateTime(now.year, now.month - 1, 5);

      final txRepo = FakeTransactionRepository()
        ..setData([
          makeExpense(id: 1, amount: 100_000, date: today),
          makeExpense(id: 2, amount: 999_000, date: lastMonth),
        ]);

      final container = _makeContainer(txRepo: txRepo);
      addTearDown(container.dispose);

      // Start with month period
      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.month;
      await container.read(transactionVMProvider.future);
      await Future.delayed(Duration(milliseconds: 50));

      final monthlySummary = container.read(dashboardVMProvider);
      expect(monthlySummary.totalExpense, 100_000);

      // Switch to day period
      container.read(selectedPeriodProvider.notifier).state = DashboardPeriod.day;
      await Future.delayed(Duration(milliseconds: 50));

      final dailySummary = container.read(dashboardVMProvider);
      expect(dailySummary.totalExpense, 100_000); // today same result
    });
  });
}

















