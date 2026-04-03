import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/entities/category_breakdown.dart';
import '../../features/reports/domain/entities/report_summary.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/get_category_breakdown.dart';
import '../../features/reports/domain/usecases/get_report_summary.dart';
import '../../shared/models/report_period.dart';
import 'transaction_providers.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.read(databaseHelperProvider));
});

final getReportSummaryProvider = Provider<GetReportSummary>((ref) {
  return GetReportSummary(ref.read(reportRepositoryProvider));
});

final getCategoryBreakdownProvider = Provider<GetCategoryBreakdown>((ref) {
  return GetCategoryBreakdown(ref.read(reportRepositoryProvider));
});

/// Reactive state: currently selected period.
final selectedPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.monthly);

/// Reactive state: reference date for the report.
final reportReferenceDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

/// Derived: current report summary.
final reportSummaryProvider = FutureProvider<ReportSummary>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final referenceDate = ref.watch(reportReferenceDateProvider);
  return ref.read(getReportSummaryProvider).call(
        period: period,
        referenceDate: referenceDate,
      );
});

/// Derived: current category breakdown.
final categoryBreakdownProvider =
    FutureProvider<List<CategoryBreakdown>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final referenceDate = ref.watch(reportReferenceDateProvider);
  return ref.read(getCategoryBreakdownProvider).call(
        period: period,
        referenceDate: referenceDate,
      );
});
