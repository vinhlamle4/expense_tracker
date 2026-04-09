import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/fixtures.dart';
import '../../../fixtures/mocks.dart';

void main() {
  late FakeSettingsRepository repo;

  setUp(() {
    repo = FakeSettingsRepository();
  });

  // ════════════════════════════════════════════════════════════════════════
  // getSettings()
  // ════════════════════════════════════════════════════════════════════════

  group('getSettings()', () {
    test('returns default settings (system) on first call', () async {
      final s = await repo.getSettings();
      expect(s.themeMode, 'system');
      expect(s.id, 0);
    });

    test('returns the same settings on subsequent calls', () async {
      final first = await repo.getSettings();
      final second = await repo.getSettings();
      expect(first.themeMode, second.themeMode);
      expect(first.id, second.id);
    });

    test('returns pre-set settings when injected', () async {
      repo.setSetting(makeSettings(themeMode: 'dark'));
      final s = await repo.getSettings();
      expect(s.themeMode, 'dark');
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // saveThemeMode()
  // ════════════════════════════════════════════════════════════════════════

  group('saveThemeMode()', () {
    test('persists light mode', () async {
      await repo.saveThemeMode('light');

      final s = await repo.getSettings();
      expect(s.themeMode, 'light');
    });

    test('persists dark mode', () async {
      await repo.saveThemeMode('dark');

      final s = await repo.getSettings();
      expect(s.themeMode, 'dark');
    });

    test('persists system mode', () async {
      await repo.saveThemeMode('system');

      final s = await repo.getSettings();
      expect(s.themeMode, 'system');
    });

    test('switches from dark to light correctly', () async {
      await repo.saveThemeMode('dark');
      await repo.saveThemeMode('light');

      final s = await repo.getSettings();
      expect(s.themeMode, 'light');
    });

    // ── Invalid inputs ──────────────────────────────────────────────────────

    test('throws AssertionError for invalid mode string', () async {
      expect(
        () async => await repo.saveThemeMode('invalid'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError for empty string', () async {
      expect(
        () async => await repo.saveThemeMode(''),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError for capitalized Light (case-sensitive)', () async {
      expect(
        () async => await repo.saveThemeMode('Light'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError for capitalized Dark', () async {
      expect(
        () async => await repo.saveThemeMode('Dark'),
        throwsA(isA<AssertionError>()),
      );
    });

    // ── Boundary: settings id is always 0 ──────────────────────────────────

    test('settings id remains 0 after saving theme mode', () async {
      await repo.saveThemeMode('dark');
      final s = await repo.getSettings();
      expect(s.id, 0);
    });
  });
}

