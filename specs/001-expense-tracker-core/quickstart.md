# Quickstart: Expense Tracker — 001-expense-tracker-core

**Generated**: 2026-04-03  
**Branch**: `001-expense-tracker-core`

Developer quick-reference for getting the project running and contributing to this feature.

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | ≥ 3.x | https://docs.flutter.dev/get-started/install |
| Dart SDK | ≥ 3.0 | Bundled with Flutter |
| Xcode | ≥ 15 | Mac App Store (iOS builds) |
| Android Studio | Hedgehog+ | https://developer.android.com/studio |
| CocoaPods | ≥ 1.13 | `sudo gem install cocoapods` |

Verify installation:
```bash
flutter doctor -v
```

---

## Project Setup

```bash
# 1. Clone and enter repo
git clone https://github.com/vinhlamle4/expense_tracker.git
cd expense_tracker

# 2. Switch to feature branch
git checkout 001-expense-tracker-core

# 3. Get dependencies
flutter pub get

# 4. iOS — install pods (macOS only)
cd ios && pod install && cd ..

# 5. Run on connected device or simulator
flutter run
```

---

## Key Dependencies

Add to `pubspec.yaml` before starting implementation:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1    # State management
  sqflite: ^2.3.3             # Local SQLite database
  path_provider: ^2.1.3       # File system paths (DB + export)
  go_router: ^14.2.0          # Declarative routing
  intl: ^0.19.0               # Date + currency formatting
  fl_chart: ^0.68.0           # Report charts
  csv: ^6.0.0                 # CSV serialisation
  share_plus: ^9.0.0          # OS share sheet for CSV export
  shared_preferences: ^2.2.3  # Settings (currency label)
  cupertino_icons: ^1.0.8     # Already present

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.3            # Mocking for unit tests
  flutter_lints: ^6.0.0      # Already present
```

After editing `pubspec.yaml`:
```bash
flutter pub get
```

---

## Project Structure (key files to know)

```
lib/main.dart                           ← Entry point (ProviderScope + MaterialApp)
lib/app/router.dart                     ← All route definitions
lib/app/theme.dart                      ← Single ThemeData
lib/core/database/database_helper.dart  ← SQLite init & migrations
lib/core/constants/default_categories.dart ← Seed data

lib/features/<name>/domain/             ← Pure Dart business logic
lib/features/<name>/data/               ← SQLite implementations
lib/features/<name>/presentation/       ← Flutter UI + Riverpod providers

lib/shared/                             ← Cross-feature models + widgets + exceptions
```

---

## Common Development Commands

```bash
# Run all unit + widget tests
flutter test

# Run with coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run integration / smoke tests (needs running device/emulator)
flutter test integration_test/app_test.dart

# Static analysis
flutter analyze

# Format all Dart files
dart format lib/ test/ integration_test/

# Check for outdated packages
flutter pub outdated

# Build release APK (Android)
flutter build apk --release

# Build release IPA archive (iOS, macOS only)
flutter build ipa
```

---

## Database Initialisation

The `DatabaseHelper` singleton creates the SQLite database on first launch and seeds default categories. No manual setup is needed.

Database location (runtime):
- **Android**: `/data/data/com.example.expense_tracker/databases/expense_tracker.db`
- **iOS**: `<app documents>/expense_tracker.db`

To reset the database during development (deletes all data):
```bash
# Uninstall the app from the device/simulator and re-run
flutter run
```

---

## Adding a New Feature Module

1. Create the directory tree:
   ```
   lib/features/<name>/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/    ← abstract interface only
   │   └── usecases/
   ├── data/
   │   ├── models/          ← DB ↔ entity mapping
   │   └── repositories/    ← sqflite implementation
   └── presentation/
       ├── providers/
       ├── screens/
       └── widgets/
   ```
2. Add the repository `Provider` to the DI wiring file (e.g., `lib/core/providers.dart`).
3. Write domain unit tests in `test/unit/features/<name>/` **before** implementing.
4. Add widget tests in `test/widget/features/<name>/`.
5. Verify `flutter test` and `flutter analyze` pass before raising a PR.

---

## Architecture Rules (quick ref)

| Rule | Detail |
|------|--------|
| No Flutter imports in `domain/` | Domain is pure Dart |
| No `sqflite` in `domain/` | Data layer only |
| No use-case calls in `data/` | Use-cases call repositories, not the other way |
| No hardcoded colours | Use `Theme.of(context).colorScheme.*` |
| No `double` for money | Use `int` minor units always |
| Amounts displayed via | `CurrencyFormatter.format(amount)` only |

---

## Running Tests Against Spec Acceptance Scenarios

User Story tests map as follows:

| User Story | Test Location | Command |
|-----------|--------------|---------|
| US-1: Record Transaction | `test/unit/features/transactions/`, `test/widget/features/transactions/` | `flutter test test/unit/features/transactions/` |
| US-2: Categories | `test/unit/features/categories/`, `test/widget/features/categories/` | `flutter test test/unit/features/categories/` |
| US-3: Reports | `test/unit/features/reports/`, `test/widget/features/reports/` | `flutter test test/unit/features/reports/` |
| US-4: Filter & Search | `test/unit/features/transactions/` (filter queries) | `flutter test` |
| US-5: CSV Export | `test/unit/features/export/` | `flutter test test/unit/features/export/` |
| All smoke flows | `integration_test/app_test.dart` | `flutter test integration_test/app_test.dart` |

---

## Definition of Done Checklist (per feature)

Before marking any feature complete, verify:

```
[ ] All FR-xxx for this feature are implemented
[ ] flutter test passes (exit code 0)
[ ] flutter analyze reports no errors
[ ] Loading / empty / error states handled on all screens
[ ] All validation errors shown inline
[ ] Amounts display correctly (VND integer, locale formatter used)
[ ] No hardcoded colours
[ ] Clean Architecture layer rules respected
[ ] Accessibility semantic labels on icons and charts
```
