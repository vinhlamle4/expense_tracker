import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/report_period.dart';
import '../entities/category_breakdown.dart';
import '../repositories/report_repository.dart';

class GetCategoryBreakdown {
  const GetCategoryBreakdown(this._repository);

  final ReportRepository _repository;

  Future<List<CategoryBreakdown>> call({
    required ReportPeriod period,
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final dateFrom = AppDateUtils.periodStart(period, ref);
    final dateTo = AppDateUtils.periodEnd(period, ref);
    return _repository.getCategoryBreakdown(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
