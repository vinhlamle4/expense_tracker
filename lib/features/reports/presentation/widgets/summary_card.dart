import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/report_summary.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final netPositive = summary.netBalance >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.periodLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCell(
                  label: 'Income',
                  amount: summary.totalIncome,
                  color: AppTheme.incomeColor(colorScheme),
                ),
                const SizedBox(width: 16),
                _StatCell(
                  label: 'Expenses',
                  amount: summary.totalExpenses,
                  color: AppTheme.expenseColor(colorScheme),
                ),
                const SizedBox(width: 16),
                _StatCell(
                  label: 'Balance',
                  amount: summary.netBalance,
                  color: netPositive
                      ? AppTheme.incomeColor(colorScheme)
                      : AppTheme.expenseColor(colorScheme),
                  signed: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.amount,
    required this.color,
    this.signed = false,
  });

  final String label;
  final int amount;
  final Color color;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 4),
          Text(
            signed
                ? CurrencyFormatter.formatSigned(amount)
                : CurrencyFormatter.format(amount),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
