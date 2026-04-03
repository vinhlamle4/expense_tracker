import 'transaction_type.dart';

/// Immutable filter bag. All fields are nullable — absent field means no filter.
class TransactionFilters {
  const TransactionFilters({
    this.dateFrom,
    this.dateTo,
    this.type,
    this.categoryId,
    this.amountMin,
    this.amountMax,
    this.keyword,
  });

  /// Inclusive lower bound, YYYY-MM-DD.
  final String? dateFrom;

  /// Inclusive upper bound, YYYY-MM-DD.
  final String? dateTo;

  final TransactionType? type;

  final int? categoryId;

  /// Minor currency units, inclusive.
  final int? amountMin;

  /// Minor currency units, inclusive.
  final int? amountMax;

  /// Case-insensitive substring match on transaction note.
  final String? keyword;

  bool get isEmpty =>
      dateFrom == null &&
      dateTo == null &&
      type == null &&
      categoryId == null &&
      amountMin == null &&
      amountMax == null &&
      (keyword == null || keyword!.isEmpty);

  TransactionFilters copyWith({
    String? dateFrom,
    String? dateTo,
    TransactionType? type,
    int? categoryId,
    int? amountMin,
    int? amountMax,
    String? keyword,
    bool clearType = false,
    bool clearCategoryId = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearAmountMin = false,
    bool clearAmountMax = false,
    bool clearKeyword = false,
  }) =>
      TransactionFilters(
        dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
        dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
        type: clearType ? null : (type ?? this.type),
        categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
        amountMin: clearAmountMin ? null : (amountMin ?? this.amountMin),
        amountMax: clearAmountMax ? null : (amountMax ?? this.amountMax),
        keyword: clearKeyword ? null : (keyword ?? this.keyword),
      );
}
