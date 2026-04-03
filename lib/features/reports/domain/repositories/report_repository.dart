import '../entities/category_breakdown.dart';
import '../entities/report_summary.dart';

abstract interface class ReportRepository {
  /// Returns income/expense summary for the given date range.
  Future<ReportSummary> getSummary({
    required String dateFrom,
    required String dateTo,
    required String periodLabel,
  });

  /// Returns expense breakdown by category for the given date range.
  Future<List<CategoryBreakdown>> getCategoryBreakdown({
    required String dateFrom,
    required String dateTo,
  });
}
