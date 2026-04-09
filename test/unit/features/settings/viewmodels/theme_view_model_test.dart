import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:expense_tracker/shared/providers/settings_providers.dart';
import 'package:expense_tracker/shared/providers/database_provider.dart';

import '../../../../fixtures/fixtures.dart';
import '../../../../fixtures/mocks.dart';

ProviderContainer _makeContainer({FakeSettingsRepository? settingsRepo}) {
  final repo = settingsRepo ?? FakeSettingsRepository();
  return ProviderContainer(
    overrides: [settingsRepoProvider.overrideWithValue(repo)],
  );
}

void main() {
  // ════════════════════════════════════════════════════════════════════════
  // Initial State — Loading from Repository
  // ════════════════════════════════════════════════════════════════════════

  group('initial load', () {
    test('defaults to ThemeMode.system when settings are fresh', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final mode = await container.read(themeVMProvider.future);
      expect(mode, ThemeMode.system);
    });

    test('loads persisted dark mode on startup', () async {
      final repo = FakeSettingsRepository()
        ..setSetting(makeSettings(themeMode: 'dark'));
      final container = _makeContainer(settingsRepo: repo);
      addTearDown(container.dispose);

      final mode = await container.read(themeVMProvider.future);
      expect(mode, ThemeMode.dark);
    });

    test('loads persisted light mode on startup', () async {
      final repo = FakeSettingsRepository()
        ..setSetting(makeSettings(themeMode: 'light'));
      final container = _makeContainer(settingsRepo: repo);
      addTearDown(container.dispose);

      final mode = await container.read(themeVMProvider.future);
      expect(mode, ThemeMode.light);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // setThemeMode() — Happy Paths
  // ════════════════════════════════════════════════════════════════════════

  group('setThemeMode()', () {
    test('switching to dark updates state to ThemeMode.dark', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);
      await container.read(themeVMProvider.notifier).setThemeMode('dark');

      expect(container.read(themeVMProvider).valueOrNull, ThemeMode.dark);
    });

    test('switching to light updates state to ThemeMode.light', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);
      await container.read(themeVMProvider.notifier).setThemeMode('light');

      expect(container.read(themeVMProvider).valueOrNull, ThemeMode.light);
    });

    test('switching to system updates state to ThemeMode.system', () async {
      final repo = FakeSettingsRepository()
        ..setSetting(makeSettings(themeMode: 'dark'));
      final container = _makeContainer(settingsRepo: repo);
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);
      await container.read(themeVMProvider.notifier).setThemeMode('system');

      expect(container.read(themeVMProvider).valueOrNull, ThemeMode.system);
    });

    test('persists the selected theme mode to repository', () async {
      final repo = FakeSettingsRepository();
      final container = _makeContainer(settingsRepo: repo);
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);
      await container.read(themeVMProvider.notifier).setThemeMode('dark');

      // Repository should hold the persisted value
      final saved = await repo.getSettings();
      expect(saved.themeMode, 'dark');
    });

    test('repeated mode changes reflect latest selection', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);

      // light → dark → system
      await container.read(themeVMProvider.notifier).setThemeMode('light');
      await container.read(themeVMProvider.notifier).setThemeMode('dark');
      await container.read(themeVMProvider.notifier).setThemeMode('system');

      expect(container.read(themeVMProvider).valueOrNull, ThemeMode.system);
    });

    // ── Invalid input ────────────────────────────────────────────────────────

    test('invalid mode string throws AssertionError (caught by repo)', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);

      expect(
        () async =>
            await container.read(themeVMProvider.notifier).setThemeMode('blah'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('empty string mode throws AssertionError', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);

      expect(
        () async =>
            await container.read(themeVMProvider.notifier).setThemeMode(''),
        throwsA(isA<AssertionError>()),
      );
    });

    test('capitalised mode (Light) throws AssertionError (case-sensitive)', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);

      expect(
        () async =>
            await container.read(themeVMProvider.notifier).setThemeMode('Light'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Boundary — mode transitions
  // ════════════════════════════════════════════════════════════════════════

  group('mode transitions', () {
    test('dark → light → system round-trip', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(themeVMProvider.future);

      await container.read(themeVMProvider.notifier).setThemeMode('dark');
      expect(container.read(themeVMProvider).valueOrNull, ThemeMode.dark);

      await container.read(themeVMProvider.notifier).setThemeMode('light');
      expect(container.read(themeVMProvider).valueOrNull, ThemeMode.light);

      await container.read(themeVMProvider.notifier).setThemeMode('system');
      expect(container.read(themeVMProvider).valueOrNull, ThemeMode.system);
    });
  });
}

