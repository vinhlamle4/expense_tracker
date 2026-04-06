# Tasks: Expense Tracker Core Features

**Input**: Design documents from `specs/003-expense-tracker-core/`  
**Prerequisites**: plan.md ✅ · spec.md ✅ · checklists/requirements.md ✅  
**Tests**: Not requested — excluded from task list per spec assumptions.  
**Organization**: Tasks are grouped by implementation phase → user story, enabling incremental delivery.

## Format: `[ID] [P?] [Story?] Description`

- **[P]** — Can run in parallel (different files, no shared dependencies)
- **[Story]** — User story tag: US1…US7
- Paths follow the source tree in `plan.md`

---

## Phase 1: Setup & Data Layer

**Purpose**: Bootstrap the project, add dependencies, define Isar schemas, and wire up repositories.  
**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T001 Add all new dependencies to `pubspec.yaml` (`hooks_riverpod`, `flutter_hooks`, `isar`, `isar_flutter_libs`, `path_provider`, `fl_chart`, `csv`, `dynamic_color`, `permission_handler`) and dev deps (`isar_generator`, `build_runner`); run `flutter pub get`
- [x] T002 Create MVVM folder structure: `lib/core/database/`, `lib/core/theme/`, `lib/core/utils/`, `lib/data/models/`, `lib/data/repositories/`, `lib/features/dashboard/viewmodels/`, `lib/features/dashboard/views/`, `lib/features/transaction/viewmodels/`, `lib/features/transaction/views/`, `lib/features/settings/viewmodels/`, `lib/features/settings/views/`, `lib/shared/providers/`, `lib/shared/widgets/`
- [x] T003 [P] Create `lib/core/database/isar_database.dart` — `Isar.open()` singleton; call `await IsarDatabase.init()` before `runApp` in `main.dart`
- [x] T004 [P] Create `lib/data/models/transaction_model.dart` — `@Collection` with fields: `int id` (auto), `double amount`, `DateTime date`, `String categoryId`, `String note`, `bool isIncome`; run `dart run build_runner build` to generate `.g.dart`
- [x] T005 [P] Create `lib/data/models/category_model.dart` — `@Collection` with fields: `String id`, `String name`, `String icon`, `int colorValue`; regenerate with `build_runner`
- [x] T006 [P] Create `lib/data/models/settings_model.dart` — `@Collection` singleton (always `id = 0`) with field `String themeMode`; regenerate with `build_runner`
- [x] T007 Create `lib/data/repositories/transaction_repository.dart` — CRUD methods + `watchAll()` stream (depends on T004)
- [x] T008 [P] Create `lib/data/repositories/category_repository.dart` — CRUD + `seedDefaults()` called on first launch (depends on T005)
- [x] T009 [P] Create `lib/data/repositories/settings_repository.dart` — `getSettings()` / `saveThemeMode(String)` against singleton record id=0 (depends on T006)

**Checkpoint**: All Isar schemas generated; repositories compile; `flutter analyze` passes.

---

## Phase 2: Theme & Layout Foundation

**Purpose**: Material 3 theme, ThemeViewModel, and the app entry point scaffold.  
**⚠️ CRITICAL**: Screens cannot be built until `ThemeMode` is wired to `MaterialApp`.

- [x] T010 Create `lib/core/theme/app_theme.dart` — `AppTheme.light` and `AppTheme.dark`, both using `useMaterial3: true` and `ColorScheme.fromSeed`; no hex color literals outside this file
- [x] T011 Create `lib/features/settings/viewmodels/theme_view_model.dart` — `AsyncNotifier<ThemeMode>` that reads initial mode from `SettingsRepository` on build; exposes `setThemeMode(String)` which persists and updates state (depends on T009)
- [x] T012 Create `lib/shared/providers/settings_providers.dart` — `settingsRepoProvider`, `themeVMProvider` (depends on T003, T011)
- [x] T013 Create `lib/shared/providers/database_provider.dart` — `isarProvider` that exposes the opened `Isar` instance to all repository providers (depends on T003)
- [x] T014 Rewrite `lib/main.dart` — wrap with `ProviderScope`; open Isar via `IsarDatabase.init()` before `runApp`; use `DynamicColorBuilder` (from `dynamic_color`) to pass system color scheme to `MaterialApp`; bind `themeMode` to `themeVMProvider` via `HookConsumerWidget`; add placeholder `NavigationBar` routing to the 3 screens (depends on T010, T012, T013)

**Checkpoint**: App launches, respects system Dynamic Color, and switches between Light/Dark.

---

## Phase 3: US1 — Transaction Management (Priority: P1) 🎯 MVP

**Goal**: Users can add, edit, delete, and view transactions; Dashboard totals update reactively.  
**Independent Test**: Add transactions → verify list and balance; edit amount → verify recalculation; delete → verify removal and balance update.

- [x] T015 [P] [US1] Create `lib/shared/providers/transaction_providers.dart` — `transactionRepoProvider`, `transactionVMProvider` (depends on T013, T007)
- [x] T016 [US1] Implement `lib/features/transaction/viewmodels/transaction_view_model.dart` — `AsyncNotifier<List<Transaction>>`; methods: `addTransaction`, `updateTransaction`, `deleteTransaction`; computed getters: `totalIncome`, `totalExpense`, `balance`; watches `TransactionRepository.watchAll()` stream (depends on T007, T015)
- [x] T017 [US1] Build `lib/features/transaction/views/transaction_list_screen.dart` — `HookConsumerWidget`; shows list of transactions (date, category icon, amount, isIncome color); FAB triggers `AddEditTransactionSheet`; swipe-to-delete shows `ConfirmDialogWidget`; empty state with illustration (depends on T016)
- [x] T018 [US1] Build `lib/shared/widgets/confirm_dialog_widget.dart` — reusable M3 `AlertDialog` with configurable title, body, and confirm/cancel actions; uses `colorScheme` tokens only
- [x] T019 [US1] Build `lib/features/transaction/views/add_edit_transaction_sheet.dart` — `ModalBottomSheet` form (`HookConsumerWidget`); fields: amount (`useTextEditingController`), date picker, isIncome toggle, note; validates amount > 0 before calling ViewModel; pre-fills fields for edit mode (depends on T016, T018)
- [x] T020 [US1] Build `lib/shared/widgets/app_card_widget.dart` — thin wrapper around M3 `Card` with standardized padding from `Theme.of(context).cardTheme`; used in transaction list items and dashboard cards

**Checkpoint**: US1 fully functional and testable independently — transactions persist across restarts.

---

## Phase 4: US2 — Category Classification (Priority: P2)

**Goal**: Every transaction can be assigned a category; defaults are seeded; custom categories can be added; deleting a category reassigns orphaned transactions.  
**Independent Test**: Assign category to transaction → verify saved; create custom category → verify it appears; delete category → verify orphan reassignment.

- [x] T021 [P] [US2] Create `lib/shared/providers/category_providers.dart` — `categoryRepoProvider`, `categoryVMProvider` (depends on T013, T008)
- [x] T022 [US2] Implement category logic in `lib/data/repositories/category_repository.dart` — `seedDefaults()` pre-populates defaults (Food & Drink, Transport, Shopping, Healthcare, Salary, Other Income, Uncategorized) on first launch using `isar.writeTxn`; `deleteAndReassign(String categoryId)` moves affected transactions to `'uncategorized'` id (depends on T007, T008)
- [x] T023 [US2] Build `lib/shared/widgets/category_picker_widget.dart` — scrollable chip list of categories filtered by `isIncome`; emits selected `Category` (depends on T021)
- [x] T024 [US2] Integrate `CategoryPickerWidget` into `AddEditTransactionSheet` — show income or expense categories based on the `isIncome` toggle value; validate category selected before save (depends on T019, T023)
- [x] T025 [US2] Build `lib/features/settings/views/settings_screen.dart` category management section — list of custom categories with add/delete; delete triggers `ConfirmDialogWidget` warning about reassignment; calls `CategoryRepository.deleteAndReassign` (depends on T018, T022)

**Checkpoint**: US1 + US2 both independently functional — category names visible in transaction list.

---

## Phase 5: US3 — Dashboard with Charts (Priority: P3)

**Goal**: Dashboard shows Balance / Total Income / Total Expense for selected period with a category-breakdown chart that updates reactively.  
**Independent Test**: Pre-seed transactions across periods → verify totals and chart segments per period; add transaction → verify Dashboard updates within 1 s.

- [x] T026 [P] [US3] Create `lib/shared/providers/dashboard_providers.dart` — `dashboardVMProvider`, `selectedPeriodProvider` (StateProvider for Day/Week/Month enum) (depends on T015)
- [x] T027 [US3] Implement `lib/features/dashboard/viewmodels/dashboard_view_model.dart` — `AsyncNotifier<DashboardSummary>`; builds from `TransactionViewModel` stream; filters by selected period; computes `totalIncome`, `totalExpense`, `balance`, `categoryBreakdown` (list of `{category, amount}` for chart); rebuilds when period or transaction list changes (depends on T016, T026)
- [x] T028 [US3] Build `lib/features/dashboard/views/dashboard_screen.dart` — `HookConsumerWidget`; three summary `AppCardWidget`s (Balance, Income, Expense); period selector chips (Day / Week / Month) bound to `selectedPeriodProvider`; `fl_chart` PieChart or BarChart from `categoryBreakdown`; empty state when no data for period (depends on T020, T027)

**Checkpoint**: Dashboard reactive — creates/edits/deletes on TransactionListScreen reflect immediately in chart and totals.

---

## Phase 6: US4 — Search & Filter (Priority: P4)

**Goal**: Users can search by note text and filter by date range and/or category; criteria combine; can be cleared.  
**Independent Test**: Type query → verify filtered list; set date range → verify only range shown; apply category filter → verify; combine criteria → verify intersection; clear → verify full list restored.

- [x] T029 [P] [US4] Create `lib/shared/providers/filter_providers.dart` — `searchQueryProvider` (`StateProvider<String>`), `dateRangeFilterProvider` (`StateProvider<DateTimeRange?>`), `categoryFilterProvider` (`StateProvider<List<String>>`) (no extra dependencies)
- [x] T030 [US4] Add filter logic to `transaction_view_model.dart` — computed getter `filteredTransactions` that applies `searchQuery`, `dateRange`, and `categoryIds` from filter providers; all criteria are ANDed; updates reactively (depends on T016, T029)
- [x] T031 [US4] Build `lib/shared/widgets/search_bar_widget.dart` — M3 `SearchBar` wrapper using `useTextEditingController`; debounces input 300 ms before writing to `searchQueryProvider`; shows clear button when query non-empty (depends on T029)
- [x] T032 [US4] Build `lib/shared/widgets/filter_bottom_sheet.dart` — date range picker (calls `showDateRangePicker`) writes to `dateRangeFilterProvider`; category multi-select chip list writes to `categoryFilterProvider`; "Clear All" resets both providers (depends on T021, T029)
- [x] T033 [US4] Integrate search bar and filter button into `transaction_list_screen.dart` — `SearchBarWidget` in AppBar area; filter icon badge shows count of active filters; filter button opens `FilterBottomSheet`; list bound to `filteredTransactions` (depends on T017, T031, T032)

**Checkpoint**: Search + filter fully functional on top of US1 transaction list; no data mutation.

---

## Phase 7: US5 — Light/Dark Mode Toggle (Priority: P5)

**Goal**: User selects Light, Dark, or System; app switches immediately; choice persists across restarts without flicker.  
**Independent Test**: Toggle each mode → verify color scheme changes; close + reopen app → verify mode preserved; set System → change device OS mode → verify app follows.

- [x] T034 [US5] Add theme-mode selector to `lib/features/settings/views/settings_screen.dart` — M3 `SegmentedButton` with three options (Light / Dark / System); reads from `themeVMProvider`; on selection calls `themeViewModel.setThemeMode(mode)` (depends on T011, T025)
- [x] T035 [US5] Verify `lib/main.dart` theme binding — confirm `MaterialApp.themeMode` is driven by `themeVMProvider` watch and that `DynamicColorBuilder` correctly falls back to seed scheme when system dynamic color is unavailable (depends on T014, T034)

**Checkpoint**: Theme toggle fully functional — mode persists in Isar Settings; app starts in saved mode with no visible theme flash.

---

## Phase 8: US6 — CSV Export (Priority: P6)

**Goal**: Tap "Export to CSV" in Settings; file saved to the device's public **Downloads** folder; confirmation shows path; filtered subset exported when filters active.  
**Independent Test**: Add transactions → export → verify file in Downloads folder with correct header + row count; apply category filter → export → verify only filtered rows; test rationale dialog and denied-permission message on Android.

- [x] T036 [P] [US6] Implement `lib/core/utils/csv_export_service.dart` — `Future<File> exportToCsv(List<Transaction> transactions, List<Category> categories)`; builds CSV with header `Date,Type,Category,Amount,Note`; maps `categoryId` → name; writes to the device's public **Downloads** folder (Android: `getExternalStorageDirectory()` + `Download/` sub-path or `MediaStore` API; iOS: app Documents directory exposed via Files app); generates a timestamped filename (e.g., `transactions_2026-04-06.csv`); if a file with the same name exists, overwrites or appends an index suffix; throws typed `ExportException` on failure; cleans up partial file on error (depends on T007, T008)
- [x] T037 [US6] Add "Export to CSV" button to `settings_screen.dart` — delegates permission check to `PermissionService` before calling `CsvExportService`; shows `SnackBar` with file path and "Open" / "Share" quick actions on success; shows error `SnackBar` with actionable guidance on failure or permanent permission denial (depends on T025, T030, T036, T039)

**Checkpoint**: CSV file written to device Downloads folder; visible in native file manager; openable in Files / spreadsheet app; export respects active filters.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Finalize navigation, loading/error states, accessibility, M3 compliance, and enforce Security & Permissions standards across all screens.

- [x] T038 [P] Install and configure `permission_handler` in `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, and `ios/Runner/Info.plist` (ensure all required permissions for storage/export are present)
- [x] T039 [P] Implement `PermissionService` in `lib/core/utils/permission_service.dart` — centralize all permission checks/requests, rationale dialogs, and denial handling per Security & Permissions rules
- [x] T040 Refactor CSV export logic in `csv_export_service.dart` and all call sites to use `PermissionService` for permission checks/requests (no direct permission logic in Widgets)
- [x] T041 Audit all features for correct use of `permission_handler` and rationale dialogs per Constitution VI; ensure all permission logic is in ViewModel/Service, not Widgets
- [x] T041b Storage & Data Handling audit — verify CSV writes target the public Downloads folder; confirm no background or automatic writes to public storage; validate Android Scoped Storage and iOS File Sharing compliance per Constitution VI
- [x] T042 [P] Finalize `NavigationBar` in `lib/main.dart` — three destinations: Dashboard, Transactions, Settings; M3 `NavigationBar` widget; preserve scroll position per tab using `AutomaticKeepAliveClientMixin` on each screen (depends on T017, T028, T025)
- [x] T043 [P] Add loading and error states to all `AsyncValue` consumers — each `HookConsumerWidget` wraps `when(data:, loading:, error:)` with M3 `CircularProgressIndicator` and `ErrorWidget`; no unhandled `AsyncValue.error` states
- [x] T044 [P] M3 color audit — `grep` for hex color literals (`0xFF`, `Color(`, `Colors.`) outside `app_theme.dart`; replace any violations with `Theme.of(context).colorScheme` tokens; document any intentional exceptions inline
- [x] T045 [P] Add `Semantics` labels to all interactive widgets — FAB, swipe-to-delete, SegmentedButton, category chips, period selector; verify minimum 48×48 dp touch targets
- [x] T046 Run `dart run build_runner build --delete-conflicting-outputs` to ensure all Isar `.g.dart` files are up to date; verify `flutter analyze` reports zero errors and zero warnings
- [x] T047 Smoke-test both Light and Dark modes on iOS Simulator and Android Emulator — verify no hardcoded colors, no overflow errors, no missing empty states

---

## Phase 10: US7 — External Export & Sharing (Priority: P7)

**Goal**: Exported CSV appears in the device's public Downloads folder; user can open it in Excel/Sheets or share it via Email/Zalo directly from the export confirmation; permission rationale shown; denial handled gracefully.  
**Independent Test**: Trigger export → open native file manager → confirm file in Downloads with timestamped name; tap "Open" → spreadsheet app opens; tap "Share" → OS share sheet appears; deny permission → rationale dialog shown → guidance to Settings shown.

- [x] T048 [US7] Update `lib/core/utils/csv_export_service.dart` — ensure the target path resolves correctly to the public Downloads folder on both Android (using `path_provider`'s external storage + `Download/` sub-directory, or `MediaStore` API for Android 10+) and iOS (app Documents directory accessible via Files app); generate timestamped filename; handle filename collision (overwrite or indexed suffix) (depends on T036)
- [x] T049 [US7] Add "Open" quick action to the export success `SnackBar` or dialog in `settings_screen.dart` — use `open_filex` or platform channel to open the CSV with the OS-default app chooser (e.g., Excel, Google Sheets); handle the case where no compatible app is installed with a user-friendly message (depends on T037)
- [x] T050 [US7] Add "Share" quick action to the export success `SnackBar` or dialog — use `share_plus` package to invoke the OS share sheet with the exported file attached; allow sharing via Email, Zalo, or any installed app that accepts file attachments (depends on T037)
- [x] T051 [P] [US7] Update `pubspec.yaml` to add `share_plus` and `open_filex` (or equivalent) with pinned version constraints per Constitution V; run `flutter pub get`
- [ ] T052 [US7] Verify end-to-end on Android Emulator: export → file visible in Downloads via Files app → open in Google Sheets → share via Gmail; verify permission rationale dialog and denial guidance flow (depends on T048, T049, T050)
- [ ] T053 [P] [US7] Verify end-to-end on iOS Simulator: export → file accessible via Files app → open in Numbers or Google Sheets → share via Mail (depends on T048, T049, T050)

**Checkpoint**: Exported CSV is discoverable in Downloads, openable in a spreadsheet app, and shareable via the OS share sheet — without the user needing to navigate hidden system folders.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Theme Foundation)**: Depends on Phase 1 completion — **blocks all UI work**
- **Phase 3–8 (User Stories US1–US6)**: All depend on Phase 1 + 2 completion; stories can proceed in priority order or in parallel if staffed
- **Phase 9 (Polish)**: Depends on all US1–US6 stories being complete
- **Phase 10 (US7 — External Export & Sharing)**: Depends on Phase 8 (US6) and Phase 9 (T038–T039 permission infrastructure)

### Within Each Phase

- Models (T004–T006) before repositories (T007–T009)
- Repositories before providers (T013, T015, T021, T026, T029)
- Providers before ViewModels, ViewModels before Views
- Shared widgets before screens that consume them

### Parallel Opportunities

- All `[P]` tasks within a phase can run simultaneously (different files)
- T004, T005, T006 — three model files, fully parallel
- T007, T008, T009 — three repository files, parallel after models
- T015, T021, T026, T029 — provider files, parallel after database provider
- T038, T039, T040, T041, T041b — polish tasks, all parallel
- T051, T052, T053 — US7 verification tasks, parallel after T048–T050

---

## Implementation Strategy

### MVP First (US1 only — Phases 1–3)

1. Complete Phase 1: Setup & Data Layer
2. Complete Phase 2: Theme & Layout Foundation
3. Complete Phase 3: US1 Transaction Management
4. **STOP and VALIDATE**: Add/edit/delete transactions; balance correct; data persists
5. Continue to Phase 4 (US2) only after MVP validation passes

### Incremental Delivery

| After Phase | What Works |
|---|---|
| 1 + 2 | App launches, M3 theme, Light/Dark from OS, Isar ready |
| + Phase 3 (US1) | Full transaction CRUD + balance calculation ← **Demo-able MVP** |
| + Phase 4 (US2) | Categories assigned and visible |
| + Phase 5 (US3) | Dashboard chart + period selector reactive |
| + Phase 6 (US4) | Search and filter live |
| + Phase 7 (US5) | Theme toggle + persistence |
| + Phase 8 (US6) | CSV export to device Downloads folder |
| + Phase 9 | Production-ready: accessible, audited, permission-compliant, zero analyze warnings |
| + Phase 10 (US7) | Exported CSV discoverable in Downloads; "Open" in Excel/Sheets; "Share" via Email/Zalo |

---

## Notes

- `[P]` = different files, no shared state dependencies — run in parallel
- Always run `flutter analyze` after each phase before moving on
- Commit after each phase or logical group (e.g., all 3 models together)
- Widget files MUST NOT import `isar` or `*_repository.dart` directly — violation of Constitution Principle I
- All colors in feature code MUST use `Theme.of(context).colorScheme` — violation of Constitution Principle II
- `HookConsumerWidget` is default; document any `ConsumerWidget` choice with a comment
- CSV exports MUST write to the public Downloads folder, not `getApplicationDocumentsDirectory()` — violation of Constitution Principle VI (Storage & Data Handling)
- Permission rationale dialog MUST precede the OS permission prompt — no direct `Permission.*.request()` without first showing rationale (Constitution Principle VI)
