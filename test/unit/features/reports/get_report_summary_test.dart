import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/reports/domain/entities/report_summary.dart';
import 'package:expense_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_report_summary.dart';
import 'package:expense_tracker/shared/models/report_period.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReportRepository extends Mock implements ReportRepository {}

ReportSummary _summary({int income = 0, int expenses = 0}) =>
    ReportSummary(
      totalIncome: income,
      totalExpenses: expenses,
      periodLabel: 'Test',
    );

void main() {
  late _MockReportRepository repository;
  late GetReportSummary sut;

  setUp(() {
    repository = _MockReportRepository();
    sut = GetReportSummary(repository);
    registerFallbackValue('');
  });

  group('period boundaries', () {
    final ref = DateTime(2024, 6, 15); // A Wednesday

    test('daily: dateFrom == dateTo == ref date', () async {
      final expectedFrom = AppDateUtils.periodStart(ReportPeriod.daily, ref);
      final expectedTo = AppDateUtils.periodEnd(ReportPeriod.daily, ref);

      when(() => repository.getSummary(
            dateFrom: expectedFrom,
            dateTo: expectedTo,
            periodLabel: any(named: 'periodLabel'),
          )).thenAnswer((_) async => _summary(income: 100));

      final result = await sut.call(period: ReportPeriod.daily, referenceDate: ref);
      expect(result.totalIncome, 100);
      expect(expectedFrom, equals(expectedTo));
    });

    test('weekly: starts on Monday, ends on Sunday', () async {
      final weekStart = AppDateUtils.periodStart(ReportPeriod.weekly, ref);
      final weekEnd = AppDateUtils.periodEnd(ReportPeriod.weekly, ref);

      // ref is a Saturday (June 15 2024 is actually a Saturday)
      final startDate = DateTime.parse(weekStart);
      final endDate = DateTime.parse(weekEnd);

      // Monday to Sunday
      expect(startDate.weekday, 1); // Monday
      expect(endDate.weekday, 7); // Sunday
      expect(endDate.difference(startDate).inDays, 6);
    });

    test('monthly: starts on 1st, ends on last day of month', () async {
      final monthStart = AppDateUtils.periodStart(ReportPeriod.monthly, ref);
      final monthEnd = AppDateUtils.periodEnd(ReportPeriod.monthly, ref);

      expect(monthStart, equals('2024-06-01'));
      expect(monthEnd, equals('2024-06-30'));
    });
  });

  group('GetReportSummary.call', () {
    test('returns summary with correct totals', () async {
      final ref = DateTime(2024, 1, 15);
      final from = AppDateUtils.periodStart(ReportPeriod.monthly, ref);
      final to = AppDateUtils.periodEnd(ReportPeriod.monthly, ref);
      when(() => repository.getSummary(
            dateFrom: from,
            dateTo: to,
            periodLabel: any(named: 'periodLabel'),
          )).thenAnswer((_) async =>
          _summary(income: 500000, expenses: 300000));

      final result = await sut.call(
          period: ReportPeriod.monthly, referenceDate: ref);

      expect(result.totalIncome, 500000);
      expect(result.totalExpenses, 300000);
      expect(result.netBalance, 200000);
    });

    test('empty period returns zeros', () async {
      final ref = DateTime(2024, 1, 15);
      final from = AppDateUtils.periodStart(ReportPeriod.monthly, ref);
      final to = AppDateUtils.periodEnd(ReportPeriod.monthly, ref);
      when(() => repository.getSummary(
            dateFrom: from,
            dateTo: to,
            periodLabel: any(named: 'periodLabel'),
          )).thenAnswer((_) async => _summary());

      final result = await sut.call(
          period: ReportPeriod.monthly, referenceDate: ref);

      expect(result.totalIncome, 0);
      expect(result.totalExpenses, 0);
      expect(result.netBalance, 0);
    });
  });
}
