import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/report_providers.dart';
import '../../../../shared/models/report_period.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../widgets/category_breakdown_list.dart';
import '../widgets/summary_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const periods = ReportPeriod.values;
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return DefaultTabController(
      length: periods.length,
      initialIndex: periods.indexOf(selectedPeriod),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: TabBar(
            onTap: (index) =>
                ref.read(selectedPeriodProvider.notifier).state =
                    periods[index],
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: periods
              .map((period) => _PeriodReport(period: period))
              .toList(),
        ),
      ),
    );
  }
}

class _PeriodReport extends ConsumerWidget {
  const _PeriodReport({required this.period});

  final ReportPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportSummaryProvider);
    final breakdownAsync = ref.watch(categoryBreakdownProvider);

    return summaryAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () {
          ref.invalidate(reportSummaryProvider);
          ref.invalidate(categoryBreakdownProvider);
        },
      ),
      data: (summary) {
        if (summary.totalIncome == 0 && summary.totalExpenses == 0) {
          return const EmptyState(
            title: 'No transactions',
            subtitle: 'Add some transactions to see your report',
            icon: Icons.bar_chart_outlined,
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              SummaryCard(summary: summary),
              const SizedBox(height: 8),
              breakdownAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => const SizedBox.shrink(),
                data: (breakdown) {
                  if (breakdown.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Expense Breakdown',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      // Pie chart (T068) with Semantics (T091)
                      Semantics(
                        label: 'Pie chart: expense breakdown by category',
                        child: SizedBox(
                          height: 200,
                          child: PieChart(
                          PieChartData(
                            sections: breakdown.map((item) {
                              final colour = _parseHex(item.categoryColour, context);
                              return PieChartSectionData(
                                value: item.total.toDouble(),
                                color: colour,
                                title:
                                    '${item.percentage.toStringAsFixed(0)}%',
                                radius: 60,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeData.estimateBrightnessForColor(colour) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      ),
                      CategoryBreakdownList(items: breakdown),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _parseHex(String hex, BuildContext context) {
    try {
      final h = hex.replaceAll('#', '');
      final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
      return Color(value);
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
