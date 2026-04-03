import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../shared/exceptions/domain_exceptions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_input.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const _table = 'categories';

  Future<Database> get _db => _dbHelper.database;

  @override
  Future<List<Category>> getCategories() async {
    final db = await _db;
    final rows =
        await db.query(_table, orderBy: 'is_system DESC, name ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<Category> getCategoryById(int id) async {
    final db = await _db;
    final rows =
        await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) throw CategoryNotFoundException(id);
    return CategoryModel.fromMap(rows.first);
  }

  @override
  Future<Category> createCategory(CategoryInput input) async {
    final db = await _db;

    final existing = await db.query(
      _table,
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [input.name.trim()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw CategoryNameExistsException(input.name.trim());
    }

    final id = await db.insert(
      _table,
      CategoryModel.toInsertMap(
        name: input.name.trim(),
        icon: input.icon,
        colour: input.colour,
      ),
    );
    return getCategoryById(id);
  }

  @override
  Future<Category> updateCategory(int id, CategoryInput input) async {
    final existing = await getCategoryById(id);
    if (existing.isSystem) throw const SystemCategoryException();

    final db = await _db;
    final duplicate = await db.query(
      _table,
      where: 'LOWER(name) = LOWER(?) AND id != ?',
      whereArgs: [input.name.trim(), id],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw CategoryNameExistsException(input.name.trim());
    }

    await db.update(
      _table,
      CategoryModel.toUpdateMap(
        name: input.name.trim(),
        icon: input.icon,
        colour: input.colour,
      ),
      where: 'id = ?',
      whereArgs: [id],
    );
    return getCategoryById(id);
  }

  @override
  Future<void> deleteCategory(int id) async {
    final category = await getCategoryById(id);
    if (category.isSystem) throw const SystemCategoryException();

    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
