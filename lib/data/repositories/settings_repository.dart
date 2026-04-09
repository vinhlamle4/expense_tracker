import 'package:isar/isar.dart';

import '../models/settings_model.dart';

// coverage:ignore-file
class SettingsRepository {
  SettingsRepository(this._isar);

  final Isar _isar;

  Future<SettingsModel> getSettings() async {
    final existing = await _isar.settingsModels.get(0);
    if (existing != null) return existing;
    // First launch — write and return default settings.
    final defaults = SettingsModel();
    await _isar.writeTxn(() => _isar.settingsModels.put(defaults));
    return defaults;
  }

  Future<void> saveThemeMode(String mode) async {
    assert(
      ['light', 'dark', 'system'].contains(mode),
      'Invalid themeMode: $mode',
    );
    final settings = await getSettings();
    settings.themeMode = mode;
    await _isar.writeTxn(() => _isar.settingsModels.put(settings));
  }
}

