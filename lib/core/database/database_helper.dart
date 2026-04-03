import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

import '../constants/default_categories.dart';
import 'migrations/v1_initial_schema.dart';

/// Singleton database helper. Initialised once on first access.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createCategoriesTable);
    await db.execute(createTransactionsTable);
    await db.execute(createIndexDate);
    await db.execute(createIndexCategory);
    await db.execute(createIndexTypeDate);
    await _seedCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations dispatched here by version number.
    // e.g. if (oldVersion < 2) await _migrateV2(db);
  }

  Future<void> _seedCategories(Database db) async {
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final cat in defaultCategories) {
      batch.insert('categories', {
        ...cat,
        'created_at': now,
        'updated_at': now,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Closes the database. Call during app shutdown if needed.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
