import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/transaction_providers.dart';
import '../../../../shared/models/paginated_result.dart';
import '../../../search_filter/presentation/providers/filter_provider.dart';
import '../../domain/entities/transaction.dart';

class TransactionListNotifier
    extends StateNotifier<AsyncValue<PaginatedResult<Transaction>>> {
  TransactionListNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;

  Future<void> load({int page = 1}) async {
    state = const AsyncValue.loading();
    final filters = _ref.read(filterProvider);
    final getTransactions = _ref.read(getTransactionsProvider);
    state = await AsyncValue.guard(
      () => getTransactions(filters: filters, page: page),
    );
  }

  Future<void> refresh() => load();
}

final transactionListProvider = StateNotifierProvider.autoDispose<
    TransactionListNotifier, AsyncValue<PaginatedResult<Transaction>>>(
  (ref) {
    // Re-load whenever filters change
    ref.listen(filterProvider, (prev, next) {
      ref.notifier.load();
    });
    return TransactionListNotifier(ref);
  },
);

