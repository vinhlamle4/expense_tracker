---
description: "Task list for Expense Tracker — 001-expense-tracker-core"
---

# Tasks: Expense Tracker — Ứng dụng quản lý chi tiêu cá nhân

**Input**: Design documents from `/specs/001-expense-tracker-core/`  
**Prerequisites**: plan.md ✅ spec.md ✅ research.md ✅ data-model.md ✅ contracts/ ✅  
**Generated**: 2026-04-03  
**Architecture**: Local-only Flutter app — no backend, no REST API, SQLite on-device via `sqflite`

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no cross-task dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- All paths are relative to workspace root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Clean, runnable Flutter project with all dependencies, routing, theming, and DI scaffold wired up. No feature-specific code.

- [X] T0XX Add all required dependencies to `pubspec.yaml` (flutter_riverpod, sqflite, path_provider, go_router, intl, fl_chart, csv, share_plus, shared_preferences, mocktail)
- [X] T0XX Create full `lib/` directory tree per plan.md project structure (`app/`, `core/`, `features/`, `shared/`)
- [X] T0XX [P] Update `analysis_options.yaml` with strict lint rules (prefer_final_locals, avoid_print, etc.)
- [X] T0XX [P] Create `lib/app/theme.dart` — single Material 3 `ThemeData` with `ColorScheme.fromSeed`; no hardcoded colours
- [X] T0XX [P] Create `lib/app/router.dart` — `GoRouter` with 3-tab `ShellRoute` (Reports | Transactions | Settings); `initialLocation: '/reports'`; remove Dashboard stub
- [X] T0XX Update `lib/main.dart` — wrap with `ProviderScope`, reference router and theme from `lib/app/`; remove generated demo code

**Checkpoint**: `flutter run` succeeds; app launches to the Reports screen; `flutter analyze` passes.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Database, shared models, utilities and shared widgets that ALL user stories depend on. MUST be complete before any feature work begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T0XX Create `lib/core/database/database_helper.dart` — singleton `sqflite` init, `PRAGMA user_version`, `onUpgrade` migration dispatcher
- [X] T0XX Create `lib/core/database/migrations/v1_initial_schema.dart` — full DDL from data-model.md (`categories`, `transactions` tables, 3 indexes: `idx_transactions_date`, `idx_transactions_category`, `idx_transactions_type_date`)
- [X] T0XX Create `lib/core/constants/default_categories.dart` — 8 built-in category seed rows (Food, Transport, Shopping, Health, Entertainment, Bills, Income, Uncategorized) with `is_system = 1`
- [X] T0XX Extend `DatabaseHelper.onCreate` to execute seed insert for default categories on first launch
- [X] T0XX Create `lib/shared/models/transaction_filters.dart` — `TransactionFilters` value object (dateFrom, dateTo, type, categoryId, amountMin, amountMax, keyword; all nullable)
- [X] T0XX [P] Create `lib/shared/models/paginated_result.dart` — generic `PaginatedResult<T>` (items, totalCount, page, pageSize, hasMore)
- [X] T0XX [P] Create `lib/shared/models/report_period.dart` — `ReportPeriod` enum (`daily`, `weekly`, `monthly`)
- [X] T0XX [P] Create `lib/shared/exceptions/domain_exceptions.dart` — `TransactionNotFoundException`, `CategoryNotFoundException`, `SystemCategoryException`, `CategoryNameExistsException`, `EmptyExportException`, `ValidationException`
- [X] T0XX [P] Create `lib/shared/widgets/empty_state.dart` — reusable empty-state widget (icon + title + subtitle)
- [X] T0XX [P] Create `lib/shared/widgets/error_state.dart` — reusable error-state widget (message + retry button callback)
- [X] T0XX [P] Create `lib/shared/widgets/loading_indicator.dart` — centered `CircularProgressIndicator` wrapper
- [X] T0XX [P] Create `lib/core/utils/currency_formatter.dart` — `CurrencyFormatter.format(int amount)` → locale-aware VND string (e.g., `"85.000 ₫"`)
- [X] T0XX [P] Create `lib/core/utils/date_utils.dart` — `DateUtils.periodStart/End(ReportPeriod, DateTime)` for daily/weekly/monthly boundaries; ISO week (Monday start)

**Checkpoint**: All shared infrastructure compiles; `flutter test` passes (no test yet, but no compilation errors).

---

## Phase 3: User Story 1 — Record a Transaction (Priority: P1) 🎯 MVP

**Goal**: Full CRUD for transactions — add, view, edit, delete — with dashboard total update.

**Independent Test**: Launch app → tap FAB → fill form (amount=85000, type=Expense, category=Food, date=today) → confirm → see entry at top of list with correct values; edit amount → see update; delete with confirm → entry removed.

### Domain Layer

- [X] T0XX [US1] Create `lib/features/transactions/domain/entities/transaction.dart` — `Transaction` entity (id, amount, type, categoryId, categoryName, date, note, createdAt, updatedAt) — pure Dart, no Flutter
- [X] T0XX [P] [US1] Create `lib/features/transactions/domain/entities/transaction_input.dart` — `TransactionInput` value object (amount, type, categoryId, date, note?)
- [X] T0XX [US1] Create `lib/features/transactions/domain/repositories/transaction_repository.dart` — abstract `TransactionRepository` interface (getTransactions, countTransactions, createTransaction, updateTransaction, deleteTransaction)
- [X] T0XX [P] [US1] Create `lib/features/transactions/domain/usecases/create_transaction.dart` — `CreateTransaction` use-case with `TransactionValidator` (amount > 0, valid date ≥ 1970-01-01, note ≤ 500 chars)
- [X] T0XX [P] [US1] Create `lib/features/transactions/domain/usecases/update_transaction.dart` — `UpdateTransaction` use-case; same validation; throws `TransactionNotFoundException`
- [X] T0XX [P] [US1] Create `lib/features/transactions/domain/usecases/delete_transaction.dart` — `DeleteTransaction` use-case; throws `TransactionNotFoundException`
- [X] T0XX [P] [US1] Create `lib/features/transactions/domain/usecases/get_transactions.dart` — `GetTransactions` use-case; delegates to repository with filters + pagination

### Data Layer

- [X] T0XX [US1] Create `lib/features/transactions/data/models/transaction_model.dart` — `TransactionModel` with `fromMap(Map)` and `toMap()` for sqflite; JOIN-aware (includes `category_name`, `icon`, `colour` from categories table)
- [X] T0XX [US1] Implement insert + read in `lib/features/transactions/data/repositories/transaction_repository_impl.dart` — `createTransaction` (INSERT + return row), `getTransactions` with full WHERE clause from data-model.md query pattern, LIMIT/OFFSET pagination
- [X] T0XX [US1] Implement `countTransactions` (same WHERE, no LIMIT), `updateTransaction` (UPDATE + return refreshed row) and `deleteTransaction` (DELETE by id) in `transaction_repository_impl.dart`

### Presentation Layer

- [X] T0XX [US1] Create `lib/core/providers/transaction_providers.dart` — Riverpod providers for `DatabaseHelper`, `TransactionRepositoryImpl`, `CreateTransaction`, `UpdateTransaction`, `DeleteTransaction`, `GetTransactions`
- [X] T0XX [US1] Create `lib/features/transactions/presentation/providers/transaction_list_provider.dart` — `StateNotifierProvider<TransactionListNotifier, AsyncValue<PaginatedResult<Transaction>>>` loading page 1 of transactions
- [X] T0XX [US1] Create `lib/features/transactions/presentation/widgets/transaction_tile.dart` — list tile showing date, category icon+name, note preview, amount (colour-coded income/expense)
- [X] T0XX [US1] Create `lib/features/transactions/presentation/screens/transaction_list_screen.dart` — `ConsumerWidget` with `ListView.builder` (lazy-load), `EmptyState`, `LoadingIndicator`, `ErrorState`; FAB → Add; tap tile → Edit; long-press or swipe → Delete confirm dialog
- [X] T0XX [US1] Create `lib/features/transactions/presentation/screens/add_edit_transaction_screen.dart` — form with: amount `TextField`, income/expense `SegmentedButton`, category `DropdownButton` (from provider), `DatePicker`, note `TextField`; inline validation error display
- [X] T0XX [US1] Wire Add/Edit routes in `lib/app/router.dart` (named routes `/transactions/add`, `/transactions/edit/:id`); supply pre-filled transaction to edit form via route extra
- [X] T0XX [US1] ~~Create `lib/features/transactions/presentation/widgets/dashboard_summary.dart`~~ — **Removed**: summary card merged into `ReportsScreen` (current-month tab). Dashboard tab eliminated in favour of Reports-first navigation.

### Unit & Widget Tests

- [X] T0XX [US1] Unit test `CreateTransaction` (happy path, amount=0 throws, negative throws, missing category throws) in `test/unit/features/transactions/create_transaction_test.dart`
- [X] T0XX [P] [US1] Unit test `UpdateTransaction` + `DeleteTransaction` (not-found throws, valid input succeeds) in `test/unit/features/transactions/update_delete_transaction_test.dart`
- [X] T0XX [P] [US1] Unit test `GetTransactions` (pagination: page 1 returns 50, page 2 returns remainder; empty list returns `PaginatedResult` with `hasMore=false`) in `test/unit/features/transactions/get_transactions_test.dart`
- [X] T0XX [P] [US1] Widget test `TransactionListScreen` — renders list from mock provider, shows `EmptyState` when list is empty, shows `LoadingIndicator` while loading in `test/widget/features/transactions/transaction_list_screen_test.dart`
- [X] T0XX [P] [US1] Widget test `AddEditTransactionScreen` — submit with no amount shows "Amount is required"; amount=0 shows "Amount must be greater than 0"; valid submit calls use-case in `test/widget/features/transactions/add_edit_transaction_screen_test.dart`

**Checkpoint**: US1 fully functional and independently testable.

---

## Phase 4: User Story 2 — Manage Categories (Priority: P2)

**Goal**: Create/rename/delete custom categories; built-in categories protected; categories populate the transaction form picker.

**Independent Test**: Settings → Categories → create "Gym" (green, `fitness_center` icon) → verify appears in category list and transaction form picker; delete a category with transactions → confirm dialog warns → deletion reassigns to Uncategorized.

### Domain Layer

- [X] T0XX [US2] Create `lib/features/categories/domain/entities/category.dart` — `Category` entity (id, name, icon, colour, isSystem, createdAt, updatedAt) — pure Dart
- [X] T0XX [P] [US2] Create `lib/features/categories/domain/entities/category_input.dart` — `CategoryInput` (name, icon?, colour?)
- [X] T0XX [US2] Create `lib/features/categories/domain/repositories/category_repository.dart` — abstract `CategoryRepository` (getCategories, createCategory, updateCategory, deleteCategory)
- [X] T0XX [P] [US2] Create `lib/features/categories/domain/usecases/get_categories.dart` — `GetCategories` use-case
- [X] T0XX [P] [US2] Create `lib/features/categories/domain/usecases/create_category.dart` — `CreateCategory` use-case with `CategoryValidator` (name non-empty, ≤ 100 chars, valid hex colour); throws `CategoryNameExistsException` on duplicate
- [X] T0XX [P] [US2] Create `lib/features/categories/domain/usecases/update_category.dart` — `UpdateCategory` use-case; throws `SystemCategoryException` for is_system=true categories
- [X] T0XX [P] [US2] Create `lib/features/categories/domain/usecases/delete_category.dart` — `DeleteCategory` use-case: (1) UPDATE transactions SET category_id=8 WHERE category_id=id, (2) DELETE category; throws `SystemCategoryException` for system categories

### Data Layer

- [X] T0XX [US2] Create `lib/features/categories/data/models/category_model.dart` — `CategoryModel` with `fromMap` / `toMap`
- [X] T0XX [US2] Implement `CategoryRepositoryImpl` in `lib/features/categories/data/repositories/category_repository_impl.dart` — all 4 operations; `getCategories` returns system categories first, then custom alphabetically

### Presentation Layer

- [X] T0XX [US2] Create `lib/core/providers/category_providers.dart` — Riverpod providers for `CategoryRepositoryImpl`, `GetCategories`, `CreateCategory`, `UpdateCategory`, `DeleteCategory`
- [X] T0XX [US2] Create `lib/features/categories/presentation/screens/category_list_screen.dart` — list with system badge chip; add/edit via bottom sheet or push route; swipe-to-delete (disabled for system categories)
- [X] T0XX [US2] Create `lib/features/categories/presentation/screens/add_edit_category_screen.dart` — TextFields for name; Material icon name picker (searchable grid); colour hex TextField with preview swatch; inline validation
- [X] T0XX [US2] Replace the stub category picker in `add_edit_transaction_screen.dart` with real `GetCategories` data from provider; display icon + colour swatch beside category name
- [X] T0XX [US2] Wire category routes in `lib/app/router.dart` (`/settings/categories`, `/settings/categories/add`, `/settings/categories/edit/:id`); add Settings entry point to bottom nav or drawer

### Unit & Widget Tests

- [X] T0XX [US2] Unit test `CreateCategory`, `UpdateCategory`, `DeleteCategory` (duplicate name throws, system category throws, valid input succeeds, transaction reassignment verified) in `test/unit/features/categories/`
- [X] T0XX [P] [US2] Widget test `CategoryListScreen` — system category delete button disabled; custom category shows delete option in `test/widget/features/categories/category_list_screen_test.dart`

**Checkpoint**: US1 + US2 independently functional. Transaction form uses real categories. Deleting a category reassigns transactions.

---

## Phase 5: User Story 3 — View Spending Reports (Priority: P3)

**Goal**: Reports screen with Daily/Weekly/Monthly totals, per-category expense breakdown, and optional chart.

**Independent Test**: Add 3 expense transactions (Food ×2, Transport ×1) in current month; open Reports → Monthly; verify totalIncome=0, totalExpenses=sum of 3 amounts, each category shows correct total and percentage.

### Domain Layer

- [X] T0XX [US3] Create `lib/features/reports/domain/entities/report_summary.dart` — `ReportSummary` (totalIncome, totalExpenses, netBalance, periodLabel)
- [X] T0XX [P] [US3] Create `lib/features/reports/domain/entities/category_breakdown.dart` — `CategoryBreakdown` (categoryId, categoryName, categoryIcon, categoryColour, total, percentage)
- [X] T0XX [US3] Create `lib/features/reports/domain/repositories/report_repository.dart` — abstract `ReportRepository` (`getSummary`, `getCategoryBreakdown`)
- [X] T0XX [P] [US3] Create `lib/features/reports/domain/usecases/get_report_summary.dart` — `GetReportSummary` use-case; delegates to `ReportRepository` with resolved period boundaries
- [X] T0XX [P] [US3] Create `lib/features/reports/domain/usecases/get_category_breakdown.dart` — `GetCategoryBreakdown` use-case; delegates to `ReportRepository`

### Data Layer

- [X] T0XX [US3] Implement `ReportRepositoryImpl` in `lib/features/reports/data/repositories/report_repository_impl.dart`:  
  - `getSummary`: SQL `SUM(CASE WHEN type=... THEN amount ELSE 0 END)` with period date range;  
  - `getCategoryBreakdown`: SQL `GROUP BY category_id` with `ROUND(100.0 * total / :totalExpenses, 1)`;  
  - Both return empty/zero results (not null) when no transactions found
- [X] T0XX [US3] Create `lib/core/providers/report_providers.dart` — Riverpod providers for `ReportRepositoryImpl`, `GetReportSummary`, `GetCategoryBreakdown`; period state provider (defaults to `monthly`, referenceDate = today)

### Presentation Layer

- [X] T0XX [US3] Create `lib/features/reports/presentation/widgets/summary_card.dart` — card showing income (green), expenses (red), net balance (blue/red depending on sign) with `CurrencyFormatter`
- [X] T0XX [P] [US3] Create `lib/features/reports/presentation/widgets/category_breakdown_list.dart` — `ListView` of category rows (icon, name, total amount, percentage bar/text)
- [X] T0XX [US3] Create `lib/features/reports/presentation/screens/reports_screen.dart` — `DefaultTabController` with Daily/Weekly/Monthly tabs; `SummaryCard` + `CategoryBreakdownList` per tab; `EmptyState` when no data; `LoadingIndicator` while async
- [X] T0XX [US3] Add `fl_chart` `PieChart` or `BarChart` to `reports_screen.dart` for category breakdown — accessible with `Semantics` labels (category name + percentage)
- [X] T0XX [US3] `ReportsScreen` now serves as the primary home view — Monthly tab shows current-month summary (replaces the removed dashboard_summary widget)
- [X] T0XX [US3] Wire `/reports` route in `lib/app/router.dart`; add Reports tab to bottom navigation bar

### Unit & Widget Tests

- [X] T0XX [US3] Unit test `GetReportSummary` period boundaries — daily (single day), weekly (Monday–Sunday), monthly (1st–last day) correctness; empty period returns zeros in `test/unit/features/reports/get_report_summary_test.dart`
- [X] T0XX [P] [US3] Unit test `GetCategoryBreakdown` — percentage calculation, single-category=100%, omit categories with 0 expense in `test/unit/features/reports/get_category_breakdown_test.dart`
- [X] T0XX [P] [US3] Widget test `ReportsScreen` — period tab switch triggers provider reload; empty state shown when data list is empty in `test/widget/features/reports/reports_screen_test.dart`

**Checkpoint**: US1 + US2 + US3 independently functional. Reports screen (home tab) shows live aggregated data.

---

## Phase 6: User Story 4 — Search and Filter Transactions (Priority: P4)

**Goal**: Combinable filters (date range, type, category, amount range) + keyword search on the transaction list.

**Independent Test**: Add 5 transactions across 2 categories and 2 types; apply type=Expense + category=Food → list shows only 2 matching rows; search "coffee" → narrows further; clear all → all 5 return.

### Presentation Layer

- [X] T0XX [US4] Create `lib/features/search_filter/presentation/providers/filter_provider.dart` — `StateNotifierProvider<FilterNotifier, TransactionFilters>` (update per-field, clear-all action)
- [X] T0XX [US4] Wire `filter_provider` into `transaction_list_provider.dart` — `TransactionListNotifier` watches `filterProvider` and passes current `TransactionFilters` to `GetTransactions`
- [X] T0XX [US4] Create `lib/features/search_filter/presentation/filter_sheet.dart` — modal bottom sheet with:  
  - Date range: two `DatePicker` fields (dateFrom, dateTo) with `dateFrom ≤ dateTo` validation  
  - Type: segmented toggle (All / Income / Expense)  
  - Category: dropdown populated from `GetCategories` provider  
  - Amount range: two `TextField`s (min, max) with `amountMin ≤ amountMax` validation  
  - Apply + Reset buttons
- [X] T0XX [US4] Create `lib/features/search_filter/presentation/widgets/active_filters_bar.dart` — horizontal row of `FilterChip`s for each active filter with individual × dismiss; "Clear All" button shown when ≥ 1 filter active
- [X] T0XX [US4] Add search `TextField` to `TransactionListScreen` app bar (input updates `filterProvider.keyword`); show `EmptyState` with "No transactions match your filters" when filtered list is empty
- [X] T0XX [US4] Insert `ActiveFiltersBar` between search bar and the `ListView` in `transaction_list_screen.dart`

### Unit & Widget Tests

- [X] T0XX [US4] Unit test combined filter query — dateFrom+dateTo+type+categoryId+keyword all applied simultaneously returns only matching rows using in-memory SQLite in `test/unit/features/transactions/get_transactions_filter_test.dart`
- [X] T0XX [P] [US4] Widget test `FilterSheet` — date range validation error shown when dateTo < dateFrom; Apply populates `filterProvider` in `test/widget/features/search_filter/filter_sheet_test.dart`

**Checkpoint**: US1–US4 independently functional. Transaction list is filterable + searchable.

---

## Phase 7: User Story 5 — Export Transactions to CSV (Priority: P5)

**Goal**: Save all or filtered transactions to a UTF-8 BOM CSV file on device storage, confirm via SnackBar, and optionally share via the OS share sheet.

**Independent Test**: Add 10 transactions; tap Save CSV in transaction list app bar; SnackBar shows filename; file is visible in Files app (iOS) or file manager (Android); open in Numbers/Excel → 7 columns, correct values, non-ASCII note characters display correctly.

### Domain Layer

- [X] T0XX [US5] Create `lib/features/export/domain/repositories/export_repository.dart` — abstract `ExportRepository` (`exportToCsv({TransactionFilters?})` → returns absolute file path `String`)
- [X] T0XX [US5] Create `lib/features/export/domain/usecases/export_to_csv.dart` — `ExportToCsv` use-case; calls `ExportRepository.exportToCsv`; throws `EmptyExportException` if no transactions match

### Data Layer

- [X] T0XX [US5] Create `lib/features/export/data/csv_export_service.dart` — `CsvExportService`:  
  - Builds 7-column rows: Date, Type, Amount, Currency, Category, Note, Created At  
  - Prepends UTF-8 BOM `\uFEFF` to file content  
  - Uses `csv` package `ListToCsvConverter` for correct comma/newline quoting  
  - **Android**: saves to `getExternalStorageDirectory()` (app-specific external, visible in file managers, no permission on API 29+)  
  - **iOS**: saves to `getApplicationDocumentsDirectory()` (exposed to Files app via `UIFileSharingEnabled`)  
  - Filename: `expense_tracker_YYYY-MM-DD_<unix-ms>.csv`
- [X] T0XX [US5] Implement `ExportRepositoryImpl` in `lib/features/export/data/repositories/export_repository_impl.dart` — queries ALL matching transactions (no pagination) via `TransactionRepositoryImpl`, delegates CSV serialisation to `CsvExportService`

### Platform Configuration

- [X] T0XX [US5] Add `UIFileSharingEnabled = true` and `LSSupportsOpeningDocumentsInPlace = true` to `ios/Runner/Info.plist` so CSV files in Documents are accessible via the iOS Files app
- [X] T0XX [US5] Add `WRITE_EXTERNAL_STORAGE` permission with `android:maxSdkVersion="28"` to `android/app/src/main/AndroidManifest.xml` (only needed for Android ≤ 9; scoped storage on API 29+ requires no permission for app-specific external directory)

### Presentation Layer

- [X] T0XX [US5] Create `lib/core/providers/export_providers.dart` — Riverpod provider for `ExportRepositoryImpl` and `ExportToCsv` use-case
- [X] T0XX [US5] Add Save CSV `IconButton` (download icon) to `TransactionListScreen` app bar — passes current `filterProvider` state to `ExportToCsv`; on success shows a SnackBar with the saved filename and a \"Share\" action that invokes `Share.shareXFiles([XFile(path)])` (share_plus)
- [X] T0XX [US5] Show `SnackBar("Nothing to export — add some transactions first")` when `EmptyExportException` is caught in `transaction_list_screen.dart`

### Unit Test

- [X] T0XX [US5] Unit test CSV generation — verify: header row present, 7 columns correct, UTF-8 BOM prefix, fields with commas/newlines are quoted, Amount is integer (no decimal), note=null exported as empty string in `test/unit/features/export/csv_export_test.dart`

**Checkpoint**: All 5 user stories independently functional and testable end-to-end.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Performance, accessibility, responsive layout, and smoke test validation.

- [X] T0XX Run `flutter run --profile` on mid-range Android device; measure cold start — MUST be ≤ 2 s; if exceeded, defer `DatabaseHelper.seed` to an async isolate
- [X] T0XX [P] Add `Semantics` labels to all `IconButton`s, `fl_chart` chart widgets (`PieChart`/`BarChart` `pieTouchData`), and category colour swatches across all screens
- [X] T0XX [P] Validate responsive layout at 320 dp and 428 dp widths for all 5 primary screens using `flutter test --device-id` or `DevicePreview`; fix any overflow errors
- [X] T0XX [P] Audit every amount-displaying widget — confirm all use `CurrencyFormatter.format(int)` and none use raw `double` or `toString()` on amounts
- [X] T0XX [P] Run `flutter analyze`; resolve all warnings, hints, and lints to zero
- [X] T0XX [P] Write integration smoke test in `integration_test/app_test.dart` covering all 4 flows: (1) add transaction → appears in list + Reports totals update, (2) delete category → transactions reassigned to Uncategorized, (3) apply filter + export → CSV contains only filtered rows, (4) open Reports → Monthly totals match manual calculation

**Checkpoint**: All 95 tasks complete; `flutter test && flutter analyze` green; smoke tests pass on device.

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1: Setup
  └── Phase 2: Foundational  ← BLOCKER: nothing starts without this
        ├── Phase 3: US1 (Record Transaction)  ← P1, MVP
        │     └── Phase 6: US4 (Filter & Search)  ← depends on transaction list
        │           └── Phase 7: US5 (CSV Export)  ← depends on filter state
        ├── Phase 4: US2 (Categories)  ← P2, parallel with US1 if staffed
        │     └── (integrates into US1 form at T054)
        ├── Phase 5: US3 (Reports)  ← P3, parallel after Phase 2
        └── Phase 8: Polish  ← depends on all 5 stories complete
```

### User Story Dependencies

- **US1 (P1)**: Starts after Phase 2. No story dependencies. Largest phase — DO FIRST.
- **US2 (P2)**: Starts after Phase 2. Integrates into US1 form (T054) but independently testable beforehand.
- **US3 (P3)**: Starts after Phase 2. Only needs the database + shared providers — independent of US1 UI.
- **US4 (P4)**: Starts after US1 is complete (needs transaction list screen to add filter bar).
- **US5 (P5)**: Starts after US4 is complete (export respects active filter state).

### Within Each User Story

- Domain entities → Domain repository interface → Domain use-cases → Data model → Data repository impl → Providers → Presentation → Tests

### Parallel Opportunities Per Phase

- **Phase 1**: T003, T004, T005 can run in parallel after T001+T002.
- **Phase 2**: T011–T019 can all run in parallel after T010.
- **Phase 3 (US1)**: T021, T023–T026 | T037–T041 run in parallel within their groups.
- **Phase 4 (US2)**: T043, T045–T048 | T056–T057 run in parallel within their groups.
- **Phase 5 (US3)**: T059, T061–T062 | T071–T073 run in parallel within their groups.
- **Phase 8 (Polish)**: T091–T095 all run in parallel.

---

## Parallel Example: Phase 3 (User Story 1)

```bash
# Domain use-cases (after T022 repository interface is created):
T023 Create CreateTransaction use-case
T024 Create UpdateTransaction use-case
T025 Create DeleteTransaction use-case
T026 Create GetTransactions use-case

# Unit tests (after use-cases are created):
T037 Unit test CreateTransaction
T038 Unit test UpdateTransaction + DeleteTransaction
T039 Unit test GetTransactions pagination
T040 Widget test TransactionListScreen
T041 Widget test AddEditTransactionScreen
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T006)
2. Complete Phase 2: Foundational (T007–T019) — CRITICAL gate
3. Complete Phase 3: User Story 1 (T020–T041)
4. **STOP and VALIDATE**: add a transaction, edit it, delete it, verify Reports totals update
5. Demo or ship MVP — all other stories add on top without regressions

### Incremental Delivery

1. Setup + Foundational → skeleton runs ✅
2. + US1 → functional expense recording; demo-able MVP ✅
3. + US2 → custom categories in use ✅
4. + US3 → spending reports with charts ✅
5. + US4 → filtered + searchable transaction list ✅
6. + US5 → CSV export via share sheet ✅
7. + Polish → production-quality finish ✅

### Parallel Team Strategy (2–3 developers after Phase 2)

- **Developer A**: US1 (Phase 3)
- **Developer B**: US2 (Phase 4) — integrates into US1 form at T054 after US2 domain is complete
- **Developer C**: US3 (Phase 5) — fully independent from US1/US2 UI
- Once US1 + US4 done: Developer A moves to US5
- Final: all three on Phase 8 polish together

---

## Summary

| Scope | Count |
|-------|-------|
| Total tasks | 95 |
| Phase 1 Setup | 6 |
| Phase 2 Foundational | 13 |
| Phase 3 US1 (Transactions) | 22 |
| Phase 4 US2 (Categories) | 16 |
| Phase 5 US3 (Reports) | 16 |
| Phase 6 US4 (Filter & Search) | 8 |
| Phase 7 US5 (CSV Export) | 8 |
| Phase 8 Polish | 6 |
| **Parallelizable [P] tasks** | **38** |

| Priority | MVP Scope |
|----------|-----------|
| Must-have | Phase 1–3 (Setup + Foundation + US1) |
| High value | Phase 4–5 (US2 Categories + US3 Reports) |
| Completes product | Phase 6–7 (US4 Filter + US5 Export) |
| Quality gate | Phase 8 Polish |

---

## Notes

- `[P]` tasks target different files with no incomplete-task dependencies — safe to run in parallel
- `[USx]` label enables per-story progress tracking and traceability to spec acceptance scenarios
- No backend API tasks exist — all data operations go through the local `sqflite` repository layer
- Amounts MUST always flow through `CurrencyFormatter` before display — never format inline
- Commit after each logical group; run `flutter test && flutter analyze` before each commit
