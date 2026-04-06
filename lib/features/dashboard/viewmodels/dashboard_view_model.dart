import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/providers/category_providers.dart';
import '../../../shared/providers/dashboard_providers.dart';

class CategoryAmount {
  const CategoryAmount({required this.category, required this.amount});
  final CategoryModel category;
  final double amount;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryBreakdown,
    required this.isEmpty,
  });

  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<CategoryAmount> categoryBreakdown;
  final bool isEmpty;

  static const empty = DashboardSummary(
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    categoryBreakdown: [],
    isEmpty: true,
  );
}

class DashboardViewModel extends Notifier<DashboardSummary> {
  @override
  DashboardSummary build() {
    // Watch transaction state and selected period reactively.
    final txState = ref.watch(transactionVMProvider);
    final period = ref.watch(selectedPeriodProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final transactions = txState.valueOrNull?.all ?? [];
    final categoryMap = {
      for (final c in categoriesAsync.valueOrNull ?? <CategoryModel>[]) c.id: c,
    };

    return _compute(transactions, categoryMap, period);
  }

  static DashboardSummary _compute(
    List<TransactionModel> all,
    Map<String, CategoryModel> categoryMap,
    DashboardPeriod period,
  ) {
    final now = DateTime.now();
    final filtered = all.where((t) => _inPeriod(t.date, now, period)).toList();

    if (filtered.isEmpty) return DashboardSummary.empty;

    final income = filtered
        .where((t) => t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = filtered
        .where((t) => !t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);

    // Build expense breakdown by category.
    final Map<String, double> expenseByCategory = {};
    for (final t in filtered.where((t) => !t.isIncome)) {
      expenseByCategory[t.categoryId] =
          (expenseByCategory[t.categoryId] ?? 0) + t.amount;
    }

    final breakdown = expenseByCategory.entries
        .where((e) => categoryMap.containsKey(e.key))
        .map((e) => CategoryAmount(
              category: categoryMap[e.key]!,
              amount: e.value,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return DashboardSummary(
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
      categoryBreakdown: breakdown,
      isEmpty: false,
    );
  }

  static bool _inPeriod(DateTime date, DateTime now, DashboardPeriod period) {
    return switch (period) {
      DashboardPeriod.day =>
        date.year == now.year && date.month == now.month && date.day == now.day,
      DashboardPeriod.week => _isSameWeek(date, now),
      DashboardPeriod.month =>
        date.year == now.year && date.month == now.month,
    };
  }

  static bool _isSameWeek(DateTime a, DateTime b) {
    final startOfWeek = b.subtract(Duration(days: b.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return !a.isBefore(
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)) &&
        !a.isAfter(
            DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59));
  }
}


