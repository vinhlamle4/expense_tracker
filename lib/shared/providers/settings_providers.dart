import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/viewmodels/theme_view_model.dart';

export 'database_provider.dart' show settingsRepoProvider;

final themeVMProvider = AsyncNotifierProvider<ThemeViewModel, ThemeMode>(
  ThemeViewModel.new,
);

