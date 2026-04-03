import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/providers/report_providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/report_period.dart';

/// Card shown at the top of the transaction list screen.
/// Uses [reportSummaryProvider] with a monthly period and today's reference date.
class DashboardSummary extends ConsumerWidget {
  const DashboardSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Override to always use monthly + today for the dashboard stub
    final summaryAsync = ref.watch(
      FutureProvider.autoDispose((r) {
        return r.read(getReportSummaryProvider).call(
              period: ReportPeriod.monthly,
              referenceDate: DateTime.now(),
            );
      }),
    );

    final colorScheme = Theme.of(context).colorScheme;

    return summaryAsync.when(
      loading: () => const SizedBox(
          height: 80, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => const SizedBox.shrink(),
      data: (s) => Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Income',
                amount: s.totalIncome,
                color: AppTheme.incomeColor(colorScheme),
              ),
              _StatItem(
                label: 'Expenses',
                amount: s.totalExpenses,
                color: AppTheme.expenseColor(colorScheme),
              ),
              _StatItem(
                label: 'Balance',
                amount: s.netBalance,
                color: s.netBalance >= 0
                    ? AppTheme.incomeColor(colorScheme)
                    : AppTheme.expenseColor(colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount.abs()),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      );
}

