import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/transaction_filters.dart';
import '../../../../shared/models/transaction_type.dart';

class FilterNotifier extends StateNotifier<TransactionFilters> {
  FilterNotifier() : super(const TransactionFilters());

  void updateDateRange({String? dateFrom, String? dateTo}) {
    state = state.copyWith(dateFrom: dateFrom, dateTo: dateTo);
  }

  void updateType(TransactionType? type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  void updateCategoryId(int? categoryId) {
    state = state.copyWith(
        categoryId: categoryId, clearCategoryId: categoryId == null);
  }

  void updateAmountRange({int? min, int? max}) {
    state = state.copyWith(
      amountMin: min,
      amountMax: max,
      clearAmountMin: min == null,
      clearAmountMax: max == null,
    );
  }

  void updateKeyword(String? keyword) {
    state = state.copyWith(
        keyword: keyword?.isEmpty == true ? null : keyword,
        clearKeyword: keyword == null || keyword.isEmpty);
  }

  void clearAll() {
    state = const TransactionFilters();
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, TransactionFilters>(
  (ref) => FilterNotifier(),
);
