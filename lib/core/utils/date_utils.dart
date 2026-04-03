import '../../shared/models/report_period.dart';

/// Period boundary calculations for report queries.
/// All dates are returned as YYYY-MM-DD strings matching the DB column format.
class AppDateUtils {
  AppDateUtils._();

  /// Inclusive start date of the period containing [reference].
  static String periodStart(ReportPeriod period, DateTime reference) {
    final d = _strip(reference);
    return switch (period) {
      ReportPeriod.daily => _fmt(d),
      ReportPeriod.weekly => _fmt(d.subtract(Duration(days: d.weekday - 1))),
      ReportPeriod.monthly => _fmt(DateTime(d.year, d.month, 1)),
    };
  }

  /// Inclusive end date of the period containing [reference].
  static String periodEnd(ReportPeriod period, DateTime reference) {
    final d = _strip(reference);
    return switch (period) {
      ReportPeriod.daily => _fmt(d),
      ReportPeriod.weekly =>
        _fmt(d.add(Duration(days: DateTime.daysPerWeek - d.weekday))),
      ReportPeriod.monthly =>
        _fmt(DateTime(d.year, d.month + 1, 0)), // day 0 = last day of prev month
    };
  }

  /// Human-readable period label for display in the UI.
  static String periodLabel(ReportPeriod period, DateTime reference) {
    final d = _strip(reference);
    return switch (period) {
      ReportPeriod.daily => '${d.day.toString().padLeft(2, '0')} '
          '${_monthAbbr(d.month)} ${d.year}',
      ReportPeriod.weekly =>
        'Week ${_isoWeek(d)} · ${d.year}',
      ReportPeriod.monthly => '${_monthName(d.month)} ${d.year}',
    };
  }

  // ---------------------------------------------------------------------------

  static DateTime _strip(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static int _isoWeek(DateTime d) {
    final dayOfYear = d.difference(DateTime(d.year, 1, 1)).inDays + 1;
    final weekDay = d.weekday;
    return ((dayOfYear - weekDay + 10) / 7).floor();
  }

  static const List<String> _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _monthsAbbr = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _monthName(int m) => _months[m];
  static String _monthAbbr(int m) => _monthsAbbr[m];
}
