import 'package:expense_tracker/features/reports/domain/entities/category_breakdown.dart';
import 'package:expense_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_category_breakdown.dart';
import 'package:expense_tracker/shared/models/report_period.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReportRepository extends Mock implements ReportRepository {}

CategoryBreakdown _bd({
  int categoryId = 1,
  String name = 'Food',
  int total = 100000,
  double percentage = 100.0,
}) =>
    CategoryBreakdown(
      categoryId: categoryId,
      categoryName: name,
      categoryIcon: 'restaurant',
      categoryColour: '#E57373',
      total: total,
      percentage: percentage,
    );

void main() {
  late _MockReportRepository repository;
  late GetCategoryBreakdown sut;

  setUp(() {
    repository = _MockReportRepository();
    sut = GetCategoryBreakdown(repository);
    registerFallbackValue('');
  });

  test('single category has 100 percent', () async {
    when(() => repository.getCategoryBreakdown(
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
        )).thenAnswer((_) async => [_bd(percentage: 100.0)]);

    final result = await sut.call(
      period: ReportPeriod.monthly,
      referenceDate: DateTime(2024, 1, 15),
    );

    expect(result.length, 1);
    expect(result.first.percentage, 100.0);
  });

  test('categories with 0 expense are absent', () async {
    when(() => repository.getCategoryBreakdown(
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
        )).thenAnswer((_) async => []);

    final result = await sut.call(
      period: ReportPeriod.monthly,
      referenceDate: DateTime(2024, 1, 15),
    );

    expect(result, isEmpty);
  });

  test('percentages add up when multiple categories', () async {
    when(() => repository.getCategoryBreakdown(
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
        )).thenAnswer((_) async => [
              _bd(categoryId: 1, name: 'Food', total: 60000, percentage: 60.0),
              _bd(
                  categoryId: 2,
                  name: 'Transport',
                  total: 40000,
                  percentage: 40.0),
            ]);

    final result = await sut.call(
      period: ReportPeriod.monthly,
      referenceDate: DateTime(2024, 1, 15),
    );

    final totalPct = result.fold(0.0, (s, item) => s + item.percentage);
    expect(totalPct, closeTo(100.0, 0.1));
  });
}
