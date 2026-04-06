import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/settings_model.dart';

/// Isar singleton — opened once before [runApp].
/// All repositories receive this instance via [isarProvider].
class IsarDatabase {
  IsarDatabase._();

  static Isar? _instance;

  static Isar get instance {
    assert(_instance != null, 'IsarDatabase.init() must be called first.');
    return _instance!;
  }

  static Future<void> init() async {
    if (_instance != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema, SettingsModelSchema],
      directory: dir.path,
    );
  }
}

