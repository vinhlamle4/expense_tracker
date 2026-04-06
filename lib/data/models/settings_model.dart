import 'package:isar/isar.dart';

part 'settings_model.g.dart';

/// Singleton settings record — always stored with [id] = 0.
@collection
class SettingsModel {
  Id id = 0;

  /// One of: 'light' | 'dark' | 'system'
  String themeMode = 'system';
}

