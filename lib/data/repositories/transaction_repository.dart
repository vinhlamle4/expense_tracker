import 'package:isar/isar.dart';

import '../models/transaction_model.dart';

class TransactionRepository {
  TransactionRepository(this._isar);

  final Isar _isar;

  // ── Read ────────────────────────────────────────────────────────────────────

  Future<List<TransactionModel>> getAll() =>
      _isar.transactionModels.where().sortByDateDesc().findAll();

  Stream<List<TransactionModel>> watchAll() =>
      _isar.transactionModels.where().sortByDateDesc().watch(fireImmediately: true);

  // ── Write ───────────────────────────────────────────────────────────────────

  Future<void> add(TransactionModel transaction) =>
      _isar.writeTxn(() => _isar.transactionModels.put(transaction));

  Future<void> update(TransactionModel transaction) =>
      _isar.writeTxn(() => _isar.transactionModels.put(transaction));

  Future<void> delete(int id) =>
      _isar.writeTxn(() => _isar.transactionModels.delete(id));

  // ── Bulk ────────────────────────────────────────────────────────────────────

  /// Reassigns all transactions with [oldCategoryId] to [newCategoryId].
  Future<void> reassignCategory(String oldCategoryId, String newCategoryId) async {
    await _isar.writeTxn(() async {
      final affected = await _isar.transactionModels
          .filter()
          .categoryIdEqualTo(oldCategoryId)
          .findAll();
      for (final t in affected) {
        t.categoryId = newCategoryId;
      }
      await _isar.transactionModels.putAll(affected);
    });
  }
}

