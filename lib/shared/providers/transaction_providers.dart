import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/transaction/viewmodels/transaction_view_model.dart';

export 'database_provider.dart' show transactionRepoProvider;

final transactionVMProvider =
    AsyncNotifierProvider<TransactionViewModel, TransactionState>(
  TransactionViewModel.new,
);

