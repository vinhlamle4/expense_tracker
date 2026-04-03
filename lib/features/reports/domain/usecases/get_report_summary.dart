import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/report_period.dart';
import '../entities/report_summary.dart';
import '../repositories/report_repository.dart';

class GetReportSummary {
  const GetReportSummary(this._repository);

  final ReportRepository _repository;

  Future<ReportSummary> call({
    required ReportPeriod period,
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final dateFrom = AppDateUtils.periodStart(period, ref);
    final dateTo = AppDateUtils.periodEnd(period, ref);
    final label = AppDateUtils.periodLabel(period, ref);
    return _repository.getSummary(
      dateFrom: dateFrom,
      dateTo: dateTo,
      periodLabel: label,
    );
  }
}
