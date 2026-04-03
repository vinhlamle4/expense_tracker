class ReportSummary {
  const ReportSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.periodLabel,
  });

  final int totalIncome;
  final int totalExpenses;

  int get netBalance => totalIncome - totalExpenses;

  final String periodLabel;
}
