// ignore_for_file: avoid_hardcoded_colors
import 'package:flutter/material.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/settings_model.dart';

// ── TransactionModel builders ───────────────────────────────────────────────

int _txIdCounter = 1;

/// Creates a TransactionModel with sensible defaults.
/// [id] auto-increments if not provided.
TransactionModel makeTransaction({
  int? id,
  double amount = 100000,
  DateTime? date,
  String categoryId = 'food',
  String note = 'Test transaction',
  bool isIncome = false,
}) {
  final t = TransactionModel()
    ..amount = amount
    ..date = date ?? DateTime(2026, 4, 6)
    ..categoryId = categoryId
    ..note = note
    ..isIncome = isIncome;
  // Assign a predictable id for test equality checks
  if (id != null) t.id = id;
  return t;
}

/// Creates an income transaction.
TransactionModel makeIncome({
  int? id,
  double amount = 5000000,
  DateTime? date,
  String categoryId = 'salary',
  String note = 'Salary',
}) =>
    makeTransaction(
      id: id,
      amount: amount,
      date: date,
      categoryId: categoryId,
      note: note,
      isIncome: true,
    );

/// Creates an expense transaction.
TransactionModel makeExpense({
  int? id,
  double amount = 100000,
  DateTime? date,
  String categoryId = 'food',
  String note = 'Expense',
}) =>
    makeTransaction(
      id: id,
      amount: amount,
      date: date,
      categoryId: categoryId,
      note: note,
      isIncome: false,
    );

/// Returns a list of [count] transactions all with today's date.
List<TransactionModel> makeManyTransactions(int count, {bool isIncome = false}) =>
    List.generate(
      count,
      (i) => makeTransaction(
        id: i + 1,
        amount: 1000.0 + i,
        note: 'Transaction $i',
        isIncome: isIncome,
      ),
    );

// ── CategoryModel builders ────────────────────────────────────────────────

/// Creates a CategoryModel with sensible defaults.
CategoryModel makeCategory({
  String id = 'food',
  String name = 'Food & Drink',
  String icon = 'e56c',
  int? colorValue,
  bool isDefault = false,
}) =>
    CategoryModel()
      ..id = id
      ..name = name
      ..icon = icon
      ..colorValue = colorValue ?? Colors.orange.toARGB32()
      ..isDefault = isDefault;

/// Returns the standard default categories matching CategoryRepository._defaults.
List<CategoryModel> makeDefaultCategories() => [
      makeCategory(id: 'uncategorized', name: 'Uncategorized', isDefault: true),
      makeCategory(id: 'food', name: 'Food & Drink'),
      makeCategory(id: 'transport', name: 'Transport'),
      makeCategory(id: 'shopping', name: 'Shopping'),
      makeCategory(id: 'healthcare', name: 'Healthcare'),
      makeCategory(id: 'entertainment', name: 'Entertainment'),
      makeCategory(id: 'education', name: 'Education'),
      makeCategory(id: 'other_expense', name: 'Other Expense'),
      makeCategory(id: 'salary', name: 'Salary'),
      makeCategory(id: 'freelance', name: 'Freelance'),
      makeCategory(id: 'other_income', name: 'Other Income'),
    ];

/// Returns a Map<String, CategoryModel> for DashboardViewModel tests.
Map<String, CategoryModel> makeCategoryMap([List<CategoryModel>? categories]) {
  final cats = categories ?? makeDefaultCategories();
  return {for (final c in cats) c.id: c};
}

// ── SettingsModel builders ────────────────────────────────────────────────

/// Creates a SettingsModel with the given theme mode.
SettingsModel makeSettings({String themeMode = 'system'}) =>
    SettingsModel()..themeMode = themeMode;

