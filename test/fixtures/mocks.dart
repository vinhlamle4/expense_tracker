import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/settings_model.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/data/repositories/category_repository.dart';
import 'package:expense_tracker/data/repositories/settings_repository.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';

import 'fixtures.dart';

// ── FakeTransactionRepository ────────────────────────────────────────────────

/// In-memory fake for TransactionRepository — no Isar native code needed.
class FakeTransactionRepository extends Fake implements TransactionRepository {
  List<TransactionModel> _data = [];
  StreamController<List<TransactionModel>>? _controller;

  /// Seed the in-memory store and emit to any active stream subscribers.
  void setData(List<TransactionModel> items) {
    _data = List<TransactionModel>.from(items);
    _controller?.add(List<TransactionModel>.from(_data));
  }

  @override
  Future<List<TransactionModel>> getAll() async =>
      List<TransactionModel>.from(_data);

  @override
  Stream<List<TransactionModel>> watchAll() {
    _controller ??= StreamController<List<TransactionModel>>.broadcast();
    // Emit current data immediately (simulating fireImmediately: true)
    Future.microtask(() => _controller!.add(List<TransactionModel>.from(_data)));
    return _controller!.stream;
  }

  @override
  Future<void> add(TransactionModel t) async {
    _data.add(t);
    _controller?.add(List<TransactionModel>.from(_data));
  }

  @override
  Future<void> update(TransactionModel t) async {
    final idx = _data.indexWhere((tx) => tx.id == t.id);
    if (idx >= 0) _data[idx] = t;
    _controller?.add(List<TransactionModel>.from(_data));
  }

  @override
  Future<void> delete(int id) async {
    _data.removeWhere((t) => t.id == id);
    _controller?.add(List<TransactionModel>.from(_data));
  }

  @override
  Future<void> reassignCategory(String oldCategoryId, String newCategoryId) async {
    for (final t in _data) {
      if (t.categoryId == oldCategoryId) t.categoryId = newCategoryId;
    }
    _controller?.add(List<TransactionModel>.from(_data));
  }

  void dispose() => _controller?.close();
}

// ── FakeCategoryRepository ────────────────────────────────────────────────────

/// In-memory fake for CategoryRepository — no Isar native code needed.
class FakeCategoryRepository extends Fake implements CategoryRepository {
  List<CategoryModel> data = [];   // public for test access
  bool _seeded = false;
  final StreamController<List<CategoryModel>> _controller =
      StreamController<List<CategoryModel>>.broadcast();

  void setData(List<CategoryModel> items) {
    data = List<CategoryModel>.from(items);
    _controller.add(List<CategoryModel>.from(data));
  }

  @override
  Future<void> seedDefaults() async {
    if (_seeded) return;
    if (data.isEmpty) {
      data = makeDefaultCategories();
      _controller.add(List<CategoryModel>.from(data));
    }
    _seeded = true;
  }

  @override
  Future<List<CategoryModel>> getAll() async =>
      List<CategoryModel>.from(data);

  @override
  Stream<List<CategoryModel>> watchAll() {
    Future.microtask(() => _controller.add(List<CategoryModel>.from(data)));
    return _controller.stream;
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    try {
      return data.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(CategoryModel category) async {
    data.removeWhere((c) => c.id == category.id); // upsert
    data.add(category);
    _controller.add(List<CategoryModel>.from(data));
  }

  @override
  Future<void> delete(String id) async {
    data.removeWhere((c) => c.id == id);
    _controller.add(List<CategoryModel>.from(data));
  }

  @override
  Future<void> deleteAndReassign(
    String categoryId,
    TransactionRepository transactionRepo,
  ) async {
    await transactionRepo.reassignCategory(categoryId, 'uncategorized');
    await delete(categoryId);
  }

  void dispose() => _controller.close();
}

// ── FakeSettingsRepository ────────────────────────────────────────────────────

/// In-memory fake for SettingsRepository — no Isar native code needed.
class FakeSettingsRepository extends Fake implements SettingsRepository {
  SettingsModel _settings = makeSettings();
  bool _initialized = false;

  void setSetting(SettingsModel s) => _settings = s;

  @override
  Future<SettingsModel> getSettings() async {
    if (!_initialized) {
      _initialized = true;
    }
    return _settings;
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    assert(
      ['light', 'dark', 'system'].contains(mode),
      'Invalid themeMode: $mode',
    );
    _settings = makeSettings(themeMode: mode);
  }
}

// ── Mocktail-based Mock classes (used where verify() is needed) ──────────────

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockSettingsRepository extends Mock implements SettingsRepository {}





