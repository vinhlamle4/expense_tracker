# Implementation Plan: Expense Tracker — Ứng dụng quản lý chi tiêu cá nhân

**Branch**: `001-expense-tracker-core` | **Date**: 2026-04-03 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-expense-tracker-core/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Build a single-user personal expense tracker as a Flutter mobile app (iOS + Android). Users can record income/expense transactions, manage categories, view spending reports (daily/weekly/monthly), filter/search transactions, and export data to CSV. All data is stored locally on-device using SQLite. The app follows Clean Architecture (Presentation → Domain ← Data) with Riverpod as state manager.

## Technical Context

**Language/Version**: Dart ≥ 3.0 / Flutter ≥ 3.x  
**Primary Dependencies**: `sqflite` (local DB), `riverpod` (state management), `csv` (CSV export), `path_provider` (file paths), `share_plus` (share sheet), `fl_chart` (reports chart), `intl` (date/currency formatting)  
**Storage**: SQLite on-device via `sqflite` + `shared_preferences` for settings  
**Testing**: `flutter_test` (unit + widget), `integration_test` (smoke flows)  
**Target Platform**: iOS 15+ and Android API 26+ (mid-range devices)  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: Transaction list ≤ 200 ms for 1,000 records; reports ≤ 500 ms for 1,000 records; cold start ≤ 2 s  
**Constraints**: Offline-only, no backend, no auth; amounts stored as integers (minor currency units); UTF-8 BOM CSV output  
**Scale/Scope**: Single user, up to ~10,000 transactions; 5 primary screens

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Feature Modularity | ✅ PASS | Each of the 5 features maps to an independent module under `lib/features/` |
| II. Local-First Data & Privacy | ✅ PASS | All data persisted with `sqflite`; no remote transmission |
| III. Clean Architecture | ✅ PASS | 3-layer structure enforced: `presentation/` → `domain/` ← `data/` |
| IV. Test Coverage | ✅ PASS | Unit + widget + smoke tests required per feature before merge |
| V. Simplicity & YAGNI | ✅ PASS | Single-user MVP, no backend, no multi-currency (data model future-ready but UI not built) |

**GATE RESULT: ALL PASS — proceed to Phase 0.**

## Project Structure

### Documentation (this feature)

```text
specs/001-expense-tracker-core/
├── plan.md              ← This file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── quickstart.md        ← Phase 1 output
├── contracts/           ← Phase 1 output
│   ├── repository-interfaces.md
│   └── service-interfaces.md
└── tasks.md             ← Phase 2 output (/speckit.tasks — NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart                        # App entry point, ProviderScope, MaterialApp
├── app/
│   ├── router.dart                  # Route definitions (go_router or Navigator)
│   └── theme.dart                   # Single ThemeData (Material 3)
├── core/
│   ├── constants/
│   │   └── default_categories.dart  # Seed data for built-in categories
│   ├── database/
│   │   ├── database_helper.dart     # sqflite init, migrations
│   │   └── migrations/              # Versioned migration scripts
│   └── utils/
│       ├── currency_formatter.dart  # Locale-aware amount display
│       └── date_utils.dart          # Period boundary calculations
├── features/
│   ├── transactions/
│   │   ├── domain/
│   │   │   ├── entities/transaction.dart
│   │   │   ├── repositories/transaction_repository.dart  # interface
│   │   │   └── usecases/
│   │   │       ├── create_transaction.dart
│   │   │       ├── update_transaction.dart
│   │   │       ├── delete_transaction.dart
│   │   │       └── get_transactions.dart
│   │   ├── data/
│   │   │   ├── models/transaction_model.dart    # DB ↔ entity mapping
│   │   │   └── repositories/transaction_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/transaction_provider.dart
│   │       ├── screens/
│   │       │   ├── transaction_list_screen.dart
│   │       │   └── add_edit_transaction_screen.dart
│   │       └── widgets/
│   │           └── transaction_tile.dart
│   ├── categories/
│   │   ├── domain/ ...
│   │   ├── data/ ...
│   │   └── presentation/ ...
│   ├── reports/
│   │   ├── domain/ ...
│   │   ├── data/ ...
│   │   └── presentation/ ...
│   ├── search_filter/
│   │   └── presentation/
│   │       └── filter_sheet.dart
│   └── export/
│       ├── domain/usecases/export_to_csv.dart
│       └── data/csv_export_service.dart
└── shared/
    └── widgets/
        ├── empty_state.dart
        ├── error_state.dart
        └── loading_indicator.dart

test/
├── unit/
│   └── features/
│       ├── transactions/
│       ├── categories/
│       └── reports/
├── widget/
│   └── features/
│       ├── transactions/
│       └── reports/
└── integration/
    └── smoke_test.dart

integration_test/
└── app_test.dart
```

**Structure Decision**: Option 3 (Mobile) — `lib/features/<name>/{domain,data,presentation}` per module. No `api/` since the app is local-only. The `core/` folder holds only truly shared, stateless utilities that do not belong to any single feature.

## Complexity Tracking

No constitution violations requiring justification.

---

## Development Phases

### Phase 0: Project Setup
**Goal**: Clean, runnable foundation with database, routing, theming, and DI wired up.  
**Duration**: 0.5–1 day

**Key deliverables**:
- Runnable `flutter run` with splash → home stub
- `sqflite` database initialised with migrations
- Riverpod `ProviderScope` at root
- Material 3 theme applied
- Default categories seeded on first launch
- `analysis_options.yaml` with strict lint rules
- CI check: `flutter analyze && flutter test` passes

---

### Phase 1: Core Data Layer (Transactions)
**Goal**: Transaction CRUD working end-to-end (domain + data layers only; minimal UI stub).  
**Duration**: 1–2 days

**Key deliverables**:
- `Transaction` entity, `TransactionModel` (DB mapping)
- `TransactionRepository` interface + `sqflite` implementation
- Use-cases: `CreateTransaction`, `UpdateTransaction`, `DeleteTransaction`, `GetTransactions` (with pagination)
- Unit tests: all use-cases and repository impl

---

### Phase 2: Transactions UI
**Goal**: Users can add, view, edit, and delete transactions via a polished mobile UI.  
**Duration**: 1.5–2 days

**Key deliverables**:
- Transaction list screen (lazy-loading, date-sorted)
- Add/edit transaction form (amount, type, category picker, date picker, note)
- Delete with confirmation dialog
- Dashboard header updated on every change
- Empty state and error state handled
- Widget tests: list screen, add/edit form

---

### Phase 3: Categories Feature
**Goal**: Users can create, rename, and delete custom categories; built-in categories are protected.  
**Duration**: 1 day

**Key deliverables**:
- `Category` entity + repository + use-cases
- Category management screen (list, add, edit, delete with confirmation)
- Category picker usable from transaction form
- "Uncategorized" fallback on category deletion
- Unit tests: category use-cases; widget test: category list screen

---

### Phase 4: Filtering & Search
**Goal**: Users can filter transactions by 5 dimensions simultaneously and search by keyword.  
**Duration**: 1 day

**Key deliverables**:
- Filter bottom sheet (date range, type, category, amount range)
- Keyword search bar on transaction list
- Filter state managed via Riverpod provider
- Filters combinable (AND logic); clear-all action
- Active filter chip indicators on transaction list header
- Widget test: filter sheet; unit test: filter in repository query

---

### Phase 5: Dashboard & Reports
**Goal**: Dashboard shows current-month totals; Reports screen shows daily/weekly/monthly summaries with category breakdown.  
**Duration**: 1.5–2 days

**Key deliverables**:
- Dashboard widget: total income, expenses, net balance (current month)
- Reports screen: period selector tabs (Daily / Weekly / Monthly)
- Period totals summary card
- Category breakdown list (name, amount, percentage)
- Optional: `fl_chart` bar/pie chart for visual breakdown
- Empty state when no transactions in selected period
- Unit tests: reporting use-cases (period boundaries, total formulas)
- Widget test: reports screen

---

### Phase 6: CSV Export
**Goal**: Users can export all or filtered transactions to a UTF-8 BOM CSV via the device share sheet.  
**Duration**: 0.5–1 day

**Key deliverables**:
- `ExportToCsv` use-case
- CSV format: 7 columns, UTF-8 BOM, comma-delimited, quoted fields
- File named `expense-tracker-YYYY-MM-DD.csv`
- Export button on transaction list (respects active filters)
- Empty export guard ("Nothing to export" message)
- Unit test: CSV generation correctness

---

### Phase 7: Polish & QA
**Goal**: App is stable, accessible, and ready to demo.  
**Duration**: 1–1.5 days

**Key deliverables**:
- Cold start ≤ 2 s verified on mid-range device
- All loading / empty / error states verified on all screens
- Currency display locale-correct for VND
- Accessibility: semantic labels on charts and icon buttons
- Responsive layout validated: 320 dp – 428 dp
- Smoke/integration test: add transaction → filter → view report → export
- No errors from `flutter analyze`

---

## Milestones & Deliverables

| Milestone | After Phase | Demo-able Output |
|-----------|-------------|-----------------|
| M0: Runnable Skeleton | Phase 0 | App launches, routes work, DB initialises, categories seeded |
| M1: Data Foundation | Phase 1 | CRUD operations verified by unit tests |
| M2: Working Transactions | Phase 2 | Add/edit/delete transaction, list displayed |
| M3: Categories | Phase 3 | Create/edit/delete categories, picker in transaction form |
| M4: Filter + Search | Phase 4 | Combined filter + keyword search working |
| M5: Reports | Phase 5 | Monthly report with breakdown; dashboard totals live |
| M6: Export | Phase 6 | CSV downloaded via share sheet |
| M7: MVP Complete | Phase 7 | All 5 features polished, tests green, perf targets met |

---

## Suggested Timeline

| Phase | Duration | Notes |
|-------|----------|-------|
| Phase 0: Setup | 0.5–1 day | Critical path start |
| Phase 1: Data Layer | 1–2 days | Blocks all UI phases |
| Phase 2: Transactions UI | 1.5–2 days | Longest single phase |
| Phase 3: Categories | 1 day | Depends on Phase 1 |
| Phase 4: Filtering | 1 day | Depends on Phases 2 + 3 |
| Phase 5: Reports | 1.5–2 days | Depends on Phase 1 |
| Phase 6: Export | 0.5–1 day | Depends on Phases 2 + 4 |
| Phase 7: Polish & QA | 1–1.5 days | Final gate |
| **Total MVP** | **8–11 days** | Solo developer estimate |

**Critical path**: Phase 0 → Phase 1 → Phase 2 → Phase 5 → Phase 7

Phases 3, 4, 6 can be parallelized if multiple developers are available.

---

## Dependencies

```
Phase 0 (Setup)
  └── Phase 1 (Data Layer)
        ├── Phase 2 (Transactions UI)
        │     ├── Phase 4 (Filtering)
        │     │     └── Phase 6 (Export)
        │     └── Phase 7 (Polish)
        ├── Phase 3 (Categories)
        │     └── Phase 4 (Filtering)
        └── Phase 5 (Reports)
              └── Phase 7 (Polish)
```

**Blocking components**:
- `DatabaseHelper` and migrations must be stable before any feature data layer is implemented.
- `Category` seed data must exist before `Transaction` UI can populate the category picker.
- Riverpod provider structure must be agreed upon in Phase 0 to avoid refactors later.

---

## Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| sqflite schema changes mid-development | Medium | High | Define full schema in Phase 0; version migrations from day 1 |
| Amount display inconsistency (floats vs ints) | Medium | Medium | Enforce integer storage rule in constitution; `CurrencyFormatter` utility centralised |
| Report query performance on large datasets | Low | Medium | Use SQL aggregation (`SUM`, `GROUP BY`) — never load all rows into memory |
| Scope creep (multi-currency, budgets requested) | High | Medium | Constitution V strictly bans unconfirmed features; redirect to post-MVP list |
| Riverpod provider graph complexity | Medium | Low | Keep providers feature-scoped; `ref.watch` only within the owning feature |
| Flutter version / package incompatibilities | Low | High | Pin all package versions in `pubspec.yaml` at project start; run `flutter pub outdated` before Phase 7 |

---

## Testing Strategy

### Unit Tests (automated, required per feature)
- All domain use-cases (happy path + error path)
- Repository implementations (mock SQLite or use in-memory SQLite)
- Utility functions: `CurrencyFormatter`, `DateUtils` period boundaries, CSV row generation

### Widget Tests (automated, required per screen)
- `TransactionListScreen`: renders list, empty state, error state
- `AddEditTransactionScreen`: form validation, success submission
- `ReportsScreen`: period selector, totals display, empty state
- `CategoryListScreen`: add/edit/delete flows
- `FilterSheet`: all filter combinations

### Integration / Smoke Tests (automated, minimal)
- **Flow 1**: Add transaction → appears in list → dashboard total updates
- **Flow 2**: Create category → use in transaction → appears in report breakdown
- **Flow 3**: Apply filters → export CSV → file contains only filtered rows
- **Flow 4**: Delete category → linked transactions show "Uncategorized"

### Manual Testing (pre-release)
- Cold start timer on mid-range Android device
- VND currency display across all screens
- Share sheet opens and CSV is readable in Numbers/Excel
- Screen reader (TalkBack/VoiceOver) labels on charts

### Coverage Targets (MVP)
- Domain use-cases: **100%**
- Data repositories: **≥ 80%**
- Presentation layer: widget tests for all primary screens
- Integration: all 4 smoke flows passing

---

## Definition of Done

A feature is considered **complete** when ALL of the following are true:

- [ ] All functional requirements for the feature (from spec FR-xxx) are implemented
- [ ] All acceptance scenarios from the relevant user story pass as tests or can be verified manually
- [ ] `flutter test` exits with code 0 (no failing tests)
- [ ] `flutter analyze` reports no errors or warnings
- [ ] Loading state, empty state, and error state are handled on all data-fetching widgets
- [ ] All user-facing validation rules show inline error messages (no silent failures)
- [ ] Amount values display in correct locale format (VND integer, no decimal)
- [ ] The feature is reachable within the defined navigation flow (≤ 2 taps for primary actions)
- [ ] Accessibility semantic labels are present on interactive widgets and charts
- [ ] No hardcoded colours (all from `ThemeData`)
- [ ] Code reviewed against Clean Architecture layer rules (no cross-layer violations)

---

## Future Enhancements (Post-MVP)

| Feature | Description | Prerequisite |
|---------|-------------|-------------|
| Budgets | Set monthly spending limits per category with progress tracking | Categories ✅ |
| Multi-currency | Support USD, EUR, etc. alongside VND | Data model already int-ready; add currency field to Transaction |
| Recurring transactions | Auto-create income/expense on a schedule | Transaction CRUD ✅ |
| Authentication | PIN or biometric lock for app access | — |
| Cloud sync | Backup and restore via iCloud / Google Drive | Auth recommended |
| Data import | Import from CSV or other expense apps | Export ✅ |
| Attachments | Attach receipt photos to transactions | Local file storage |
| Widgets (home screen) | Show today's spending summary in an OS widget | — |
