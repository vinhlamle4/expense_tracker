import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/transaction_model.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/filter_providers.dart';

/// Immutable state exposed by [TransactionViewModel].
class TransactionState {
  const TransactionState({
    required this.all,
    required this.filtered,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  final List<TransactionModel> all;
  final List<TransactionModel> filtered;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  static const empty = TransactionState(
    all: [],
    filtered: [],
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
  );
}

class TransactionViewModel extends AsyncNotifier<TransactionState> {
  StreamSubscription<List<TransactionModel>>? _sub;

  @override
  Future<TransactionState> build() async {
    final repo = ref.read(transactionRepoProvider);

    // Seed categories on first launch.
    final catRepo = ref.read(categoryRepoProvider);
    await catRepo.seedDefaults();

    // Watch the DB stream → rebuild state reactively.
    _sub?.cancel();
    _sub = repo.watchAll().listen((list) {
      if (state case AsyncData()) {
        state = AsyncData(_compute(
          list,
          ref.read(searchQueryProvider),
          ref.read(dateRangeFilterProvider),
          ref.read(categoryFilterProvider),
        ));
      }
    });
    ref.onDispose(() => _sub?.cancel());

    // Also rebuild when filter providers change.
    ref.listen(searchQueryProvider, (prev, next) => _refresh());
    ref.listen(dateRangeFilterProvider, (prev, next) => _refresh());
    ref.listen(categoryFilterProvider, (prev, next) => _refresh());

    final all = await repo.getAll();
    return _compute(all, '', null, const []);
  }

  // ── Public API (called by View layer) ─────────────────────────────────────

  Future<void> addTransaction(TransactionModel t) async {
    final repo = ref.read(transactionRepoProvider);
    await repo.add(t);
  }

  Future<void> updateTransaction(TransactionModel t) async {
    final repo = ref.read(transactionRepoProvider);
    await repo.update(t);
  }

  Future<void> deleteTransaction(int id) async {
    final repo = ref.read(transactionRepoProvider);
    await repo.delete(id);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  void _refresh() {
    if (state case AsyncData(:final value)) {
      state = AsyncData(_compute(
        value.all,
        ref.read(searchQueryProvider),
        ref.read(dateRangeFilterProvider),
        ref.read(categoryFilterProvider),
      ));
    }
  }

  static TransactionState _compute(
    List<TransactionModel> all,
    String query,
    DateTimeRange? dateRange,
    List<String> categoryIds,
  ) {
    final q = query.trim().toLowerCase();

    final filtered = all.where((t) {
      if (q.isNotEmpty && !t.note.toLowerCase().contains(q)) return false;
      if (dateRange != null) {
        final d = t.date;
        if (d.isBefore(dateRange.start) ||
            d.isAfter(dateRange.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      if (categoryIds.isNotEmpty && !categoryIds.contains(t.categoryId)) {
        return false;
      }
      return true;
    }).toList();

    final income = all
        .where((t) => t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = all
        .where((t) => !t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);

    return TransactionState(
      all: all,
      filtered: filtered,
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
    );
  }
}


