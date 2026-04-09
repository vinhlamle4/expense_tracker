import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/data/models/settings_model.dart';

void main() {
  group('SettingsModel', () {
    // ── Happy paths ─────────────────────────────────────────────────────────

    test('default themeMode is system', () {
      final s = SettingsModel();
      expect(s.themeMode, 'system');
    });

    test('id is always 0 (singleton pattern)', () {
      final s1 = SettingsModel();
      final s2 = SettingsModel();
      expect(s1.id, 0);
      expect(s2.id, 0);
    });

    test('can set themeMode to light', () {
      final s = SettingsModel()..themeMode = 'light';
      expect(s.themeMode, 'light');
    });

    test('can set themeMode to dark', () {
      final s = SettingsModel()..themeMode = 'dark';
      expect(s.themeMode, 'dark');
    });

    test('can set themeMode to system', () {
      final s = SettingsModel()..themeMode = 'system';
      expect(s.themeMode, 'system');
    });

    // ── Mutations ────────────────────────────────────────────────────────────

    test('themeMode can be changed after creation', () {
      final s = SettingsModel();
      expect(s.themeMode, 'system');

      s.themeMode = 'dark';
      expect(s.themeMode, 'dark');

      s.themeMode = 'light';
      expect(s.themeMode, 'light');
    });

    // ── Boundary / invalid (at data level) ──────────────────────────────────

    test('stores arbitrary string (validation is in repository, not model)', () {
      final s = SettingsModel()..themeMode = 'anything';
      // The model itself has no validation — SettingsRepository enforces valid modes.
      expect(s.themeMode, 'anything');
    });
  });
}

