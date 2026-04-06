import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/providers/database_provider.dart';

class ThemeViewModel extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final repo = ref.read(settingsRepoProvider);
    final settings = await repo.getSettings();
    return _parse(settings.themeMode);
  }

  Future<void> setThemeMode(String mode) async {
    final repo = ref.read(settingsRepoProvider);
    await repo.saveThemeMode(mode);
    state = AsyncData(_parse(mode));
  }

  static ThemeMode _parse(String mode) => switch (mode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
