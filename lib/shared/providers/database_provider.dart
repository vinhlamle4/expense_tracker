import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../core/database/isar_database.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/transaction_repository.dart';

/// Exposes the already-opened [Isar] instance.
/// [IsarDatabase.init()] MUST be called before [runApp].
final isarProvider = Provider<Isar>((ref) => IsarDatabase.instance);

/// Repository providers — import THIS file from any ViewModel that needs a repo.
/// No ViewModel types are imported here, so there are no circular dependencies.

final transactionRepoProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(isarProvider)),
);

final categoryRepoProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(isarProvider)),
);

final settingsRepoProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(isarProvider)),
);

