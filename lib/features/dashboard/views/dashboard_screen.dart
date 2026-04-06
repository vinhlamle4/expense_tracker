import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/dashboard_providers.dart';
import '../../../shared/widgets/app_card_widget.dart';
import '../viewmodels/dashboard_view_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardVMProvider);
    final period = ref.watch(selectedPeriodProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Period selector ──────────────────────────────────────────
          Semantics(
            label: 'Select period',
            child: SegmentedButton<DashboardPeriod>(
              segments: const [
                ButtonSegment(value: DashboardPeriod.day, label: Text('Day')),
                ButtonSegment(
                    value: DashboardPeriod.week, label: Text('Week')),
                ButtonSegment(
                    value: DashboardPeriod.month, label: Text('Month')),
              ],
              selected: {period},
              onSelectionChanged: (s) => ref
                  .read(selectedPeriodProvider.notifier)
                  .state = s.first,
            ),
          ),
          const SizedBox(height: 16),

          if (summary.isEmpty) ...[
            // ── Empty state ──────────────────────────────────────────
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart,
                        size: 72, color: cs.outlineVariant),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions this period.\nAdd one to see your summary!',
                      textAlign: TextAlign.center,
                      style: tt.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // ── Summary cards ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Income',
                    amount: summary.totalIncome,
                    icon: Icons.arrow_downward,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    label: 'Expense',
                    amount: summary.totalExpense,
                    icon: Icons.arrow_upward,
                    color: cs.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SummaryCard(
              label: 'Balance',
              amount: summary.balance,
              icon: Icons.account_balance_wallet,
              color: summary.balance >= 0 ? cs.primary : cs.error,
              isLarge: true,
            ),
            const SizedBox(height: 20),

            // ── Pie chart ────────────────────────────────────────────
            if (summary.categoryBreakdown.isNotEmpty) ...[
              Text('Spending by Category', style: tt.titleMedium),
              const SizedBox(height: 12),
              _ExpensePieChart(summary: summary),
              const SizedBox(height: 16),
              _ChartLegend(summary: summary),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Private widgets ────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppCardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: tt.labelMedium),
          ]),
          const SizedBox(height: 4),
          Text(
            _fmt(amount),
            style: (isLarge ? tt.headlineSmall : tt.titleMedium)
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      NumberFormat.currency(symbol: '₫', decimalDigits: 0).format(v);
}

class _ExpensePieChart extends StatelessWidget {
  const _ExpensePieChart({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final breakdown = summary.categoryBreakdown;
    final total = breakdown.fold<double>(0, (s, c) => s + c.amount);

    final sections = breakdown.asMap().entries.map((e) {
      final item = e.value;
      final pct = total > 0 ? item.amount / total * 100 : 0.0;
      return PieChartSectionData(
        value: item.amount,
        title: '${pct.toStringAsFixed(0)}%',
        color: Color(item.category.colorValue),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: summary.categoryBreakdown.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(item.category.colorValue),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(item.category.name, style: tt.bodyMedium)),
            Text(
              NumberFormat.currency(symbol: '₫', decimalDigits: 0)
                  .format(item.amount),
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ]),
        );
      }).toList(),
    );
  }
}
