# Implementation Plan: Expense Tracker Core Features

**Branch**: `003-expense-tracker-core` | **Date**: 2026-04-06 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/003-expense-tracker-core/spec.md`

## Summary

Build six core features of the Flutter Expense Tracker — Transaction CRUD, Category Classification, Dashboard with charts, Search & Filter, Light/Dark/System theme toggle, and CSV export to the public Downloads folder — using a local-only Isar database, MVVM architecture with `hooks_riverpod` + `flutter_hooks`, and strict Material Design 3. No network calls are made at any point.

## Technical Context

**Language/Version**: Dart 3 / Flutter Latest Stable  
**Primary Dependencies**: `hooks_riverpod`, `flutter_hooks`, `isar`, `isar_flutter_libs`, `path_provider`, `fl_chart`, `csv`, `dynamic_color`, `permission_handler`  
**Storage**: Isar (local, embedded, no server) — 3 collections: `Transaction`, `Category`, `Settings`  
**Testing**: `flutter_test` (widget placeholder exists; no TDD requested — tests excluded from task list)  
**Target Platform**: iOS + Android (mobile-first)  
**Project Type**: Flutter mobile app  
**Performance Goals**: List scrolls lag-free up to 1,000 entries; search results within 500 ms; CSV export within 5 s for 1,000 rows  
**Constraints**: 100 % offline; no `http`/`dio`; theme applied before first frame (no flicker)  
**Scale/Scope**: Single user · single device · 3 main screens · 3 Isar collections

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Requirement | Status |
|-----------|-------------|--------|
| I. MVVM Architecture | All business logic in `*_view_model.dart`; Widget files MUST NOT import Isar or repositories directly | ✅ Pass |
| II. Material Design 3 | `useMaterial3: true`; `dynamic_color` package for Dynamic Color; all feature-code colors via `Theme.of(context).colorScheme` | ✅ Pass |
| III. Local-First Storage | Isar selected; no `http`/`dio`/`connectivity` introduced; theme mode persisted to `Settings` collection | ✅ Pass |
| IV. State Management | `HookConsumerWidget` preferred; `flutter_hooks` for ephemeral state; `StatefulWidget` not used | ✅ Pass |
| V. Coding Standards | `snake_case` files, `PascalCase` classes, `camelCase` vars; one widget per file; `flutter_lints ^6.0.0` active | ✅ Pass |
| VI. Security & Permissions | `permission_handler` used for all storage permission requests; rationale dialog shown before OS prompt; denial handled with guidance to Settings; all permission logic in `PermissionService` (not in Widgets); CSV exports saved to public Downloads folder per Storage & Data Handling sub-rule | ✅ Pass |

No violations. Complexity Tracking table not required.

## Data Models

### Transaction (`@Collection`)

| Field | Type | Notes |
|-------|------|-------|
| `id` | `int` | Isar auto-id |
| `amount` | `double` | Positive, non-zero |
| `date` | `DateTime` | Device local timezone |
| `categoryId` | `String` | FK → Category.id |
| `note` | `String` | Optional, defaults to `''` |
| `isIncome` | `bool` | `true` = Income, `false` = Expense |

### Category (`@Collection`)

| Field | Type | Notes |
|-------|------|-------|
| `id` | `String` | UUID or slug |
| `name` | `String` | Display name |
| `icon` | `String` | Icon code point (Material Icons) |
| `colorValue` | `int` | ARGB int for chip/icon tint |

### Settings (`@Collection` — singleton record, id = 0)

| Field | Type | Notes |
|-------|------|-------|
| `id` | `int` | Always `0` |
| `themeMode` | `String` | `'light'` \| `'dark'` \| `'system'` |

## App Architecture (MVVM)

```
Model Layer        →  Isar @Collection schemas
Repository Layer   →  TransactionRepository · CategoryRepository · SettingsRepository
ViewModel Layer    →  TransactionViewModel · DashboardViewModel · ThemeViewModel
View Layer         →  DashboardScreen · TransactionListScreen · SettingsScreen
```

- **Repositories** own all Isar read/write calls. ViewModels never import `isar` directly.  
- **TransactionViewModel** manages list state, balance calculation, search, and filter.  
- **DashboardViewModel** derives period totals and chart data from the transaction stream.  
- **ThemeViewModel** reads/writes `Settings` via `SettingsRepository`; exposes `ThemeMode` to `MaterialApp`.  
- **CategoryRepository** handles seeding defaults on first launch and CRUD for custom categories.

## Library Dependencies

### `pubspec.yaml` additions

```yaml
dependencies:
  hooks_riverpod: ^2.6.1
  flutter_hooks: ^0.21.1
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1   # platform-native Isar binaries
  path_provider: ^2.1.4
  fl_chart: ^0.70.2
  csv: ^6.0.0
  dynamic_color: ^1.7.0
  permission_handler: ^11.3.1   # Android CSV storage write

dev_dependencies:
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.13
```

> All version constraints use `^` (tightly bounded). Floating `any` constraints are prohibited per Constitution V.

## Project Structure

### Documentation (this feature)

```text
specs/003-expense-tracker-core/
├── plan.md              # This file
├── spec.md              # Feature specification
├── checklists/
│   └── requirements.md  # QA checklist (all 16 items ✅)
└── tasks.md             # Task list (/speckit.tasks output)
```

### Source Code

```text
lib/
├── main.dart                              # ProviderScope, MaterialApp, theme binding
│
├── core/
│   ├── database/
│   │   └── isar_database.dart            # Isar.open() singleton, opened before runApp
│   ├── theme/
│   │   └── app_theme.dart                # ThemeData light/dark (useMaterial3: true)
│   └── utils/
│       └── csv_export_service.dart       # CSV generation + writes to public Downloads folder
│
├── data/
│   ├── models/
│   │   ├── transaction_model.dart        # @Collection — Transaction schema
│   │   ├── category_model.dart           # @Collection — Category schema
│   │   └── settings_model.dart           # @Collection — Settings schema (singleton)
│   └── repositories/
│       ├── transaction_repository.dart   # CRUD + Stream<List<Transaction>>
│       ├── category_repository.dart      # CRUD + default-seed on first launch
│       └── settings_repository.dart     # Read/write singleton Settings record
│
├── features/
│   ├── dashboard/
│   │   ├── viewmodels/
│   │   │   └── dashboard_view_model.dart # Period totals + chart data derivation
│   │   └── views/
│   │       └── dashboard_screen.dart     # fl_chart + summary cards + period selector
│   ├── transaction/
│   │   ├── viewmodels/
│   │   │   └── transaction_view_model.dart # CRUD, balance, search, filter logic
│   │   └── views/
│   │       ├── transaction_list_screen.dart
│   │       └── add_edit_transaction_sheet.dart # BottomSheet form
│   └── settings/
│       ├── viewmodels/
│       │   └── theme_view_model.dart     # ThemeMode state + persistence
│       └── views/
│           └── settings_screen.dart      # Theme toggle + Export CSV button
│
└── shared/
    ├── providers/
    │   ├── database_provider.dart        # isarProvider (AsyncNotifierProvider)
    │   ├── transaction_providers.dart    # transactionRepoProvider, transactionVMProvider
    │   ├── category_providers.dart       # categoryRepoProvider, categoryVMProvider
    │   ├── dashboard_providers.dart      # dashboardVMProvider
    │   ├── filter_providers.dart         # searchQueryProvider, dateRangeProvider, categoryFilterProvider
    │   └── settings_providers.dart       # settingsRepoProvider, themeVMProvider
    └── widgets/
        ├── category_picker_widget.dart   # Reusable category selector chip list
        ├── search_bar_widget.dart        # M3 SearchBar wrapper
        ├── filter_bottom_sheet.dart      # Date range + category multi-filter
        ├── app_card_widget.dart          # M3 Card wrapper (no magic numbers)
        └── confirm_dialog_widget.dart    # Reusable AlertDialog (delete / category-reassign)

test/
└── widget_test.dart                     # Existing placeholder
```

**Structure Decision**: Single Flutter project, feature-first under `lib/features/`. Repositories live in `lib/data/` and are the only layer allowed to import Isar. Shared widgets in `lib/shared/widgets/` are the single source of reusable UI components (no duplication per Constitution UI/UX rules).

## Phase 1 → Phase 5 Mapping

| User's Phase | Scope |
|---|---|
| **Phase 1** — Setup & Data Layer | `pubspec.yaml` · `isar_database.dart` · all 3 models · all 3 repositories · `build_runner` |
| **Phase 2** — Theme & Layout | `app_theme.dart` · `theme_view_model.dart` · MVVM folder structure · `main.dart` scaffold |
| **Phase 3** — Core Logic (ViewModels) | `transaction_view_model.dart` · `dashboard_view_model.dart` · `filter_providers.dart` |
| **Phase 4** — UI Implementation | `dashboard_screen.dart` · `transaction_list_screen.dart` · `add_edit_transaction_sheet.dart` · `settings_screen.dart` · shared widgets |
| **Phase 5** — Utilities & Polish | `csv_export_service.dart` (writes to public Downloads folder) · `permission_service.dart` · permission rationale + denial UX · M3 color audit · performance pass |

## Complexity Tracking

> No violations to justify. All Core Principles met without exceptions or waivers.

