import '../../../../core/database/database_helper.dart';
import '../../domain/entities/category_breakdown.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  @override
  Future<ReportSummary> getSummary({
    required String dateFrom,
    required String dateTo,
    required String periodLabel,
  }) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN type = 'income'  THEN amount ELSE 0 END) AS total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS total_expenses
      FROM transactions
      WHERE date >= ? AND date <= ?
      ''',
      [dateFrom, dateTo],
    );

    final row = rows.first;
    return ReportSummary(
      totalIncome: (row['total_income'] as num? ?? 0).toInt(),
      totalExpenses: (row['total_expenses'] as num? ?? 0).toInt(),
      periodLabel: periodLabel,
    );
  }

  @override
  Future<List<CategoryBreakdown>> getCategoryBreakdown({
    required String dateFrom,
    required String dateTo,
  }) async {
    final db = await _dbHelper.database;

    // Get total expenses for the period first
    final totalRows = await db.rawQuery(
      '''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE type = 'expense' AND date >= ? AND date <= ?
      ''',
      [dateFrom, dateTo],
    );
    final totalExpenses =
        (totalRows.first['total'] as num? ?? 0).toInt();

    if (totalExpenses == 0) return [];

    final rows = await db.rawQuery(
      '''
      SELECT
        c.id AS category_id,
        c.name AS category_name,
        c.icon AS category_icon,
        c.colour AS category_colour,
        SUM(t.amount) AS total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = 'expense'
        AND t.date >= ? AND t.date <= ?
      GROUP BY c.id, c.name, c.icon, c.colour
      ORDER BY total DESC
      ''',
      [dateFrom, dateTo],
    );

    return rows.map((row) {
      final total = (row['total'] as num).toInt();
      final percentage =
          totalExpenses > 0 ? (total * 100.0 / totalExpenses) : 0.0;
      return CategoryBreakdown(
        categoryId: row['category_id'] as int,
        categoryName: row['category_name'] as String,
        categoryIcon: row['category_icon'] as String,
        categoryColour: row['category_colour'] as String,
        total: total,
        percentage: double.parse(percentage.toStringAsFixed(1)),
      );
    }).toList();
  }
}
