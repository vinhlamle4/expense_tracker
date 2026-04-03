import '../../../../core/database/database_helper.dart';
import '../../../../shared/exceptions/domain_exceptions.dart';
import '../../../../shared/models/paginated_result.dart';
import '../../../../shared/models/transaction_filters.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_input.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

const String _table = 'transactions';

/// Builds the WHERE clause and argument list from [TransactionFilters].
({String where, List<Object?> args}) _buildWhere(TransactionFilters? filters) {
  if (filters == null || filters.isEmpty) return (where: '1=1', args: []);

  final clauses = <String>[];
  final args = <Object?>[];

  if (filters.dateFrom != null) {
    clauses.add('t.date >= ?');
    args.add(filters.dateFrom);
  }
  if (filters.dateTo != null) {
    clauses.add('t.date <= ?');
    args.add(filters.dateTo);
  }
  if (filters.type != null) {
    clauses.add('t.type = ?');
    args.add(filters.type!.value);
  }
  if (filters.categoryId != null) {
    clauses.add('t.category_id = ?');
    args.add(filters.categoryId);
  }
  if (filters.amountMin != null) {
    clauses.add('t.amount >= ?');
    args.add(filters.amountMin);
  }
  if (filters.amountMax != null) {
    clauses.add('t.amount <= ?');
    args.add(filters.amountMax);
  }
  if (filters.keyword != null && filters.keyword!.isNotEmpty) {
    clauses.add('(t.note LIKE ?)');
    args.add('%${filters.keyword}%');
  }

  return (where: clauses.join(' AND '), args: args);
}

/// SQLite-backed implementation of [TransactionRepository].
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dbHelper);
  final DatabaseHelper _dbHelper;

  static const String _joinQuery = '''
    SELECT
      t.id, t.amount, t.type, t.category_id, t.date, t.note,
      t.created_at, t.updated_at,
      c.name  AS category_name,
      c.icon  AS cat_icon,
      c.colour AS cat_colour
    FROM $_table t
    JOIN categories c ON t.category_id = c.id
  ''';

  @override
  Future<PaginatedResult<Transaction>> getTransactions({
    TransactionFilters? filters,
    int page = 1,
    int pageSize = 50,
  }) async {
    final db = await _dbHelper.database;
    final (:where, :args) = _buildWhere(filters);

    final total = await _count(db, where, args);
    final offset = (page - 1) * pageSize;

    final rows = await db.rawQuery(
      '$_joinQuery WHERE $where ORDER BY t.date DESC, t.created_at DESC LIMIT ? OFFSET ?',
      [...args, pageSize, offset],
    );

    return PaginatedResult(
      items: rows.map(TransactionModel.fromMap).toList(),
      totalCount: total,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<int> countTransactions({TransactionFilters? filters}) async {
    final db = await _dbHelper.database;
    final (:where, :args) = _buildWhere(filters);
    return _count(db, where, args);
  }

  Future<int> _count(dynamic db, String where, List<Object?> args) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM $_table t WHERE $where',
      args,
    );
    return result.first['n'] as int;
  }

  @override
  Future<Transaction> createTransaction(TransactionInput input) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final id = await db.insert(
      _table,
      TransactionModel.insertMap(
        amount: input.amount,
        type: input.type.value,
        categoryId: input.categoryId,
        date: input.date,
        note: input.note,
        now: now,
      ),
    );
    return _fetchById(db, id);
  }

  @override
  Future<Transaction> updateTransaction(int id, TransactionInput input) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final count = await db.update(
      _table,
      TransactionModel.updateMap(
        amount: input.amount,
        type: input.type.value,
        categoryId: input.categoryId,
        date: input.date,
        note: input.note,
        now: now,
      ),
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count == 0) throw TransactionNotFoundException(id);
    return _fetchById(db, id);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    if (count == 0) throw TransactionNotFoundException(id);
  }

  Future<Transaction> _fetchById(dynamic db, int id) async {
    final rows = await db.rawQuery('$_joinQuery WHERE t.id = ?', [id]);
    if (rows.isEmpty) throw TransactionNotFoundException(id);
    return TransactionModel.fromMap(rows.first);
  }
}
