import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_helper.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/create_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions.dart';
import '../../features/transactions/domain/usecases/update_transaction.dart';

final databaseHelperProvider = Provider<DatabaseHelper>(
  (_) => DatabaseHelper.instance,
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final createTransactionProvider = Provider<CreateTransaction>(
  (ref) => CreateTransaction(ref.watch(transactionRepositoryProvider)),
);

final updateTransactionProvider = Provider<UpdateTransaction>(
  (ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)),
);

final deleteTransactionProvider = Provider<DeleteTransaction>(
  (ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)),
);

final getTransactionsProvider = Provider<GetTransactions>(
  (ref) => GetTransactions(ref.watch(transactionRepositoryProvider)),
);
