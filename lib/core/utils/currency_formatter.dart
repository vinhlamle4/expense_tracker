import 'package:intl/intl.dart';

/// All monetary amounts in the app are stored as integers (minor currency units).
/// This formatter is the ONLY place amounts should be converted to display strings.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vnd = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Formats [amount] (integer minor units for VND) into a display string.
  /// Example: 85000 → '85.000 ₫'
  static String format(int amount) => _vnd.format(amount);

  /// Formats with explicit sign: +85.000 ₫ or -85.000 ₫
  static String formatSigned(int amount) {
    final formatted = _vnd.format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }
}
