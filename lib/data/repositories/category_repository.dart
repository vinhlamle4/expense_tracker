import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/category_model.dart';
import 'transaction_repository.dart';

class CategoryRepository {
  CategoryRepository(this._isar);

  final Isar _isar;

  // ── Seed ────────────────────────────────────────────────────────────────────

  // ignore: avoid_hardcoded_colors — these are ARGB seed integers persisted to the
  // database, not UI colors. Widgets read Color(cat.colorValue) at runtime.
  static final List<CategoryModel> _defaults = [
    _cat('uncategorized', 'Uncategorized', 'e8ef', Colors.grey, isDefault: true),
    // Expense categories
    _cat('food', 'Food & Drink', 'e56c', Colors.orange),
    _cat('transport', 'Transport', 'e531', Colors.blue),
    _cat('shopping', 'Shopping', 'e8cc', Colors.pink),
    _cat('healthcare', 'Healthcare', 'e548', Colors.red),
    _cat('entertainment', 'Entertainment', 'e02c', Colors.purple),
    _cat('education', 'Education', 'e80c', Colors.indigo),
    _cat('other_expense', 'Other Expense', 'e8b8', Colors.blueGrey),
    // Income categories
    _cat('salary', 'Salary', 'e227', Colors.green),
    _cat('freelance', 'Freelance', 'e8d5', Colors.teal),
    _cat('other_income', 'Other Income', 'e8b8', Colors.cyan),
  ];

  static CategoryModel _cat(
    String id,
    String name,
    String icon,
    Color color, {
    bool isDefault = false,
  }) =>
      CategoryModel()
        ..id = id
        ..name = name
        ..icon = icon
        ..colorValue = color.toARGB32()
        ..isDefault = isDefault;

  /// Inserts default categories on first launch (no-op if already present).
  Future<void> seedDefaults() async {
    final existing = await _isar.categoryModels.count();
    if (existing > 0) return;
    await _isar.writeTxn(() => _isar.categoryModels.putAll(_defaults));
  }

  // ── Read ────────────────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getAll() =>
      _isar.categoryModels.where().findAll();

  Stream<List<CategoryModel>> watchAll() =>
      _isar.categoryModels.where().watch(fireImmediately: true);

  Future<CategoryModel?> getById(String id) =>
      _isar.categoryModels.get(fastHash(id));

  // ── Write ───────────────────────────────────────────────────────────────────

  Future<void> add(CategoryModel category) =>
      _isar.writeTxn(() => _isar.categoryModels.put(category));

  Future<void> delete(String id) =>
      _isar.writeTxn(() => _isar.categoryModels.delete(fastHash(id)));

  /// Deletes [categoryId] and moves all its transactions to 'uncategorized'.
  Future<void> deleteAndReassign(
    String categoryId,
    TransactionRepository transactionRepo,
  ) async {
    await transactionRepo.reassignCategory(categoryId, 'uncategorized');
    await delete(categoryId);
  }
}


