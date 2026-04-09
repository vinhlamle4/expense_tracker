# Feature Specification: Unit Testing - 80% Coverage Logic App

**Feature Branch**: `004-unit-testing-80pct`  
**Created**: 2026-04-09  
**Status**: Draft  
**Input**: User description: "Unit Testing with 80% Coverage for App Logic (ViewModels, Repositories, Services, Providers) - based on spec.md core features"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - TransactionViewModel Logic Coverage (Priority: P1)

A test developer needs to verify that the core transaction logic handles all business rules correctly. They write unit tests for TransactionViewModel to ensure transactions are created, updated, deleted, filtered by search query, filtered by date range, filtered by category, and that totals (income, expense, balance) are calculated correctly. Tests verify that the ViewModel computes the filtered transaction list based on active filters and that state changes trigger reactively.

**Why this priority**: TransactionViewModel is the heart of transaction management. Without comprehensive tests for its _compute() logic, search/filter logic, and state transitions, no other feature can be reliably validated. This is the critical path.

**Independent Test**: Can be fully tested by creating mock TransactionRepository, setting up various transactions with different amounts/types/categories/dates, applying filters (search, date range, category filters), and verifying: filtered list matches criteria, totals are calculated correctly, balance = income - expense. All without requiring UI, Dashboard, or export features.

**Acceptance Scenarios**:

1. **Given** TransactionViewModel with 5 transactions, **When** no filters are active, **Then** filtered list contains all 5 transactions and totalIncome + totalExpense sums are correct.
2. **Given** a search query "Coffee" is active, **When** _compute() is called with transactions containing notes "Coffee", "Taxi", "Salary", **Then** only the "Coffee" transaction appears in filtered list.
3. **Given** a date range filter from 2026-04-01 to 2026-04-07 is active, **When** transactions span April and May, **Then** filtered list contains only April transactions.
4. **Given** category filter ["food", "transport"] is active, **When** transactions have categories ["food", "shopping", "transport", "salary"], **Then** filtered list contains only food and transport transactions.
5. **Given** search query + date range + category filters are all active simultaneously, **When** _compute() is called, **Then** all three criteria apply (AND logic).
6. **Given** a mix of income and expense transactions, **When** _compute() is called, **Then** totalIncome sums only income transactions, totalExpense sums only expense transactions, and balance = totalIncome - totalExpense.
7. **Given** empty transaction list, **When** _compute() is called, **Then** filtered list is empty, totals are 0, and balance is 0.

---

### User Story 2 - TransactionRepository CRUD Operations (Priority: P1)

A test developer needs to verify that TransactionRepository correctly manages database operations. They write tests for add, update, delete, and bulk reassignCategory operations. Tests verify that methods call Isar correctly, handle database transactions properly, and that the repository returns correct data streams.

**Why this priority**: The repository is the data access layer. If CRUD operations don't work correctly, no data persists. This is foundational and must be 100% reliable before any ViewModel can work.

**Independent Test**: Can be fully tested by using a mock Isar database (via mocktail), calling each repository method, and verifying the correct Isar methods were invoked with correct parameters. No UI or other repositories required.

**Acceptance Scenarios**:

1. **Given** an empty Isar database, **When** add(transaction) is called, **Then** Isar.writeTxn() and transactionModels.put() are invoked with the transaction.
2. **Given** an existing transaction in the database, **When** update(modifiedTransaction) is called, **Then** Isar.writeTxn() and transactionModels.put() are invoked.
3. **Given** an existing transaction with id=5, **When** delete(5) is called, **Then** Isar.writeTxn() and transactionModels.delete(5) are invoked.
4. **Given** 3 transactions with categoryId='old_cat', **When** reassignCategory('old_cat', 'uncategorized') is called, **Then** all 3 transactions are reassigned and putAll() is invoked.
5. **Given** getAll() is called, **Then** a list of transactions sorted by date descending is returned.
6. **Given** watchAll() is called, **When** database changes, **Then** a stream emits updated lists reactively.

---

### User Story 3 - CategoryRepository Default Seeding & CRUD (Priority: P1)

A test developer needs to verify that CategoryRepository correctly initializes default categories on first launch and handles create/delete operations. Tests verify seedDefaults() idempotence, category retrieval, and the deleteAndReassign() bulk operation that moves transactions to 'uncategorized'.

**Why this priority**: Categories are required for every transaction. Without correct seeding and CRUD operations, the system cannot initialize or allow users to manage categories. This is P1 infrastructure.

**Independent Test**: Can be fully tested with mock Isar, calling seedDefaults() and verifying default categories are inserted exactly once, getAll() and getById() return correct categories, delete() removes categories, and deleteAndReassign() calls TransactionRepository.reassignCategory(). No UI or Dashboard required.

**Acceptance Scenarios**:

1. **Given** fresh database, **When** seedDefaults() is called, **Then** 11 default categories (uncategorized + 10 others) are inserted.
2. **Given** seedDefaults() was already called, **When** seedDefaults() is called again, **Then** no additional categories are inserted (idempotent).
3. **Given** categories exist in database, **When** getAll() is called, **Then** all categories are returned.
4. **Given** a category with id='food' exists, **When** getById('food') is called, **Then** CategoryModel with name='Food & Drink' is returned.
5. **Given** a category 'food' is assigned to 10 transactions, **When** deleteAndReassign('food', transactionRepo) is called, **Then** transactionRepo.reassignCategory() is invoked and 'food' category is deleted.
6. **Given** custom category created with id='freelance', **When** add(customCategory) is called, **Then** category is persisted and retrievable.

---

### User Story 4 - SettingsRepository Theme Persistence (Priority: P2)

A test developer needs to verify that SettingsRepository correctly loads, creates, and saves theme preferences. Tests verify getSettings() creates default settings on first launch, saveThemeMode() persists values, and that invalid modes are rejected.

**Why this priority**: Theme persistence is less critical than transaction/category logic but must work reliably to meet SC-003 (no visible flicker). Tests are simple and independent.

**Independent Test**: Can be fully tested with mock Isar, verifying getSettings() returns existing or creates defaults, saveThemeMode('light'/'dark'/'system') persists to database, and assertion errors catch invalid modes.

**Acceptance Scenarios**:

1. **Given** fresh database, **When** getSettings() is called, **Then** a new SettingsModel with themeMode='system' is created and returned.
2. **Given** settings with themeMode='system' exist, **When** getSettings() is called, **Then** existing settings are returned (not recreated).
3. **Given** settings exist, **When** saveThemeMode('dark') is called, **Then** themeMode is updated and persisted.
4. **Given** settings exist, **When** saveThemeMode('light') is called, **Then** themeMode is updated and persisted.
5. **Given** settings exist, **When** saveThemeMode('invalid') is called, **Then** assertion fails and exception is raised.

---

### User Story 5 - DashboardViewModel Period Filtering & Totals (Priority: P2)

A test developer needs to verify that DashboardViewModel correctly filters transactions by period (Day/Week/Month) and calculates category breakdowns. Tests verify _inPeriod(), _isSameWeek() logic, expense category grouping, and that empty periods return empty state.

**Why this priority**: Dashboard is the main value screen but depends on transaction/category logic being correct. Period filtering logic is complex and error-prone, so comprehensive tests prevent bugs.

**Independent Test**: Can be fully tested with mock transaction lists and category maps, calling _compute() with different periods and verifying filtered transactions, income/expense totals, and category breakdown match expectations. No UI, charts, or providers required.

**Acceptance Scenarios**:

1. **Given** transactions from 2026-04-05 and 2026-04-06 with today=2026-04-06, **When** _compute() called with period=DAY, **Then** only 2026-04-06 transactions included.
2. **Given** transactions across two weeks with today in week 1, **When** _compute() called with period=WEEK, **Then** only week 1 transactions included.
3. **Given** transactions from March and April with today in April, **When** _compute() called with period=MONTH, **Then** only April transactions included.
4. **Given** transactions with no data for selected period, **When** _compute() called, **Then** DashboardSummary.empty returned with all zeros.
5. **Given** 10 expense transactions with categories [food:500, transport:300, food:200], **When** _compute() called, **Then** categoryBreakdown contains food:700 and transport:300 sorted descending by amount.
6. **Given** transactions exist but categoryMap is missing keys, **When** _compute() called, **Then** missing categories are filtered out, not crashed.

---

### User Story 6 - CsvExportService File Generation & Path Resolution (Priority: P2)

A test developer needs to verify that CsvExportService correctly generates CSV files, resolves export directory paths for Android/iOS, and handles filename conflicts. Tests verify exportToCsv() generates correct CSV format, _resolveExportDirectory() handles platform differences, _resolveUniqueFile() prevents overwrites, and error handling cleans up partial files.

**Why this priority**: CSV export is important but doesn't affect core transaction/category logic. Tests verify file I/O and platform-specific paths work correctly to prevent user data loss.

**Independent Test**: Can be fully tested with mock File system and Platform, calling exportToCsv() with sample transactions/categories, verifying CSV content, directory resolution, conflict handling, and error cleanup. No UI, permissions, or actual file system required.

**Acceptance Scenarios**:

1. **Given** 3 transactions, **When** exportToCsv() called, **Then** CSV file contains header row + 3 data rows with columns [Date, Type, Category, Amount, Note].
2. **Given** Platform.isAndroid=true with external storage path, **When** _resolveExportDirectory() called, **Then** Downloads directory at /storage/emulated/0/Download returned.
3. **Given** Platform.isAndroid=false (iOS), **When** _resolveExportDirectory() called, **Then** app Documents directory returned.
4. **Given** Android external storage unavailable, **When** _resolveExportDirectory() called, **Then** falls back to app Documents directory.
5. **Given** file 'transactions_2026-04-09.csv' exists, **When** _resolveUniqueFile() called with same basename, **Then** 'transactions_2026-04-09_1.csv' returned.
6. **Given** exportToCsv() fails with exception, **When** partial file exists, **Then** file is deleted and ExportException thrown.
7. **Given** export succeeds, **When** returned File object exists, **Then** file.existsSync()=true.

---

### User Story 7 - PermissionService Rationale & Denial Handling (Priority: P3)

A test developer needs to verify that PermissionService correctly checks storage permission status, shows rationale dialogs, handles denials, and provides guidance for permanent denials. Tests verify ensureStoragePermission() flow, iOS bypass, rationale dialog display, and denial dialog behavior.

**Why this priority**: Permission handling is important for compliance but less critical than core transaction logic. Tests ensure permission flow is robust and user-friendly.

**Independent Test**: Can be fully tested with mock BuildContext, Permission, and dialog responses, calling ensureStoragePermission() with different permission states and verifying correct dialogs shown and methods called. No real permissions or file I/O required.

**Acceptance Scenarios**:

1. **Given** Platform.isIOS=true, **When** ensureStoragePermission(context) called, **Then** returns true immediately without checking permission.
2. **Given** Platform.isAndroid=true and permission already granted, **When** ensureStoragePermission(context) called, **Then** returns true immediately without showing dialog.
3. **Given** Platform.isAndroid=true and permission not granted, **When** ensureStoragePermission(context) called, **Then** _showRationaleDialog() is called first.
4. **Given** rationale dialog dismissed with false, **When** ensureStoragePermission(context) called, **Then** returns false without requesting permission.
5. **Given** rationale dialog dismissed with true, **When** ensureStoragePermission(context) called, **Then** permission.request() is called.
6. **Given** permission request denied, **When** ensureStoragePermission(context) called, **Then** _showDenialDialog() called with isPermanent=false.
7. **Given** permission request permanently denied, **When** ensureStoragePermission(context) called, **Then** _showDenialDialog() called with isPermanent=true and includes "Open Settings" button.

---

### Edge Cases

- What happens when TransactionViewModel._compute() is called with 1000+ transactions? (Must filter efficiently without timeout.)
- What happens when amount field receives invalid negative or zero values in tests? (Validation must reject; test framework should verify rejection.)
- What happens when date range filter has start date > end date? (Logic must handle gracefully or reject; tests verify behavior.)
- What happens when categoryMap in DashboardViewModel._compute() is missing referenced category IDs? (Must filter out, not crash.)
- What happens when CsvExportService encounters permission denied on file write? (ExportException thrown with clear message, partial file cleaned up.)
- What happens when Platform.isAndroid=true but /storage/emulated/0 is unavailable? (Fallback to app Documents; test verifies fallback logic.)
- What happens when _resolveUniqueFile() increments filename 100+ times? (Must handle arbitrarily high indices without overflow.)
- What happens when SettingsRepository receives theme mode with different casing (e.g., 'Light' vs 'light')? (Assertion should fail; test must verify.)
- What happens when TransactionRepository.reassignCategory() is called with non-existent oldCategoryId? (No transactions match, no-op; test verifies no crash.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-T001**: Unit tests MUST cover TransactionViewModel._compute() logic including search query filtering, date range filtering, category filtering, combined filter logic, and total calculations (income, expense, balance).
- **FR-T002**: Unit tests MUST cover TransactionViewModel state transitions and reactive updates when filters change or database updates occur.
- **FR-T003**: Unit tests MUST cover TransactionRepository.add(), update(), delete(), getAll(), watchAll(), and reassignCategory() operations with mocked Isar database.
- **FR-T004**: Unit tests MUST cover CategoryRepository.seedDefaults() idempotence, getAll(), getById(), add(), delete(), and deleteAndReassign() operations.
- **FR-T005**: Unit tests MUST cover SettingsRepository.getSettings() initialization and saveThemeMode() persistence for all valid theme modes.
- **FR-T006**: Unit tests MUST cover DashboardViewModel._compute() period filtering (Day/Week/Month), category breakdown calculation, income/expense totals, and empty state handling.
- **FR-T007**: Unit tests MUST cover DashboardViewModel._inPeriod() and _isSameWeek() logic for all period types across month boundaries.
- **FR-T008**: Unit tests MUST cover CsvExportService.exportToCsv() CSV generation with correct format and columns.
- **FR-T009**: Unit tests MUST cover CsvExportService._resolveExportDirectory() platform-specific path resolution (Android vs iOS, with fallback logic).
- **FR-T010**: Unit tests MUST cover CsvExportService._resolveUniqueFile() filename conflict resolution and unique filename generation.
- **FR-T011**: Unit tests MUST cover CsvExportService error handling: partial file cleanup on export failure, ExportException messaging.
- **FR-T012**: Unit tests MUST cover PermissionService.ensureStoragePermission() complete flow: iOS bypass, Android permission check, rationale dialog, request, denial handling.
- **FR-T013**: Unit tests MUST cover PermissionService._showRationaleDialog() and _showDenialDialog() for both temporary and permanent denial cases.
- **FR-T014**: Unit tests MUST use mocktail for mocking Isar, BuildContext, Permission, File, and Directory objects.
- **FR-T015**: Unit tests MUST NOT test UI widgets or model serialization; focus solely on business logic and state management.
- **FR-T016**: Unit test suite MUST achieve 80% code coverage of logic layer (ViewModels, Repositories, Services) excluding UI and model generation files.

### Key Entities

- **Test Coverage Target**: 80% of business logic (ViewModels, Repositories, Services, Providers) excluding UI and model serialization.
- **Test Framework**: Dart test framework + mocktail for mocking.
- **Mock Targets**: Isar database, BuildContext, Permission, File I/O, Platform.
- **Test Organization**: Unit tests organized in `test/unit/` with subdirectories for each logic layer (viewmodels, repositories, services).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-T001**: 80% code coverage achieved for TransactionViewModel (all paths in _compute(), state transitions, filter logic).
- **SC-T002**: 80% code coverage achieved for TransactionRepository (all CRUD operations and bulk operations).
- **SC-T003**: 80% code coverage achieved for CategoryRepository (seeding, CRUD, deleteAndReassign).
- **SC-T004**: 80% code coverage achieved for SettingsRepository (initialization, persistence, validation).
- **SC-T005**: 80% code coverage achieved for DashboardViewModel (period filtering, category breakdown, totals calculation).
- **SC-T006**: 80% code coverage achieved for CsvExportService (CSV generation, path resolution, conflict handling, error cleanup).
- **SC-T007**: 80% code coverage achieved for PermissionService (permission flow, dialogs, iOS/Android platform differences).
- **SC-T008**: All unit tests pass consistently on local machine and CI/CD pipeline.
- **SC-T009**: Test execution completes in under 30 seconds for the full test suite.
- **SC-T010**: All edge cases identified in spec are covered by at least one test case.

## Assumptions

## Assumptions

- The app uses mocktail for mocking and Dart's built-in test framework (flutter_test).
- Isar database interactions are fully mocked; no real database instance is required during testing.
- Platform.isAndroid and Platform.isIOS are mockable and controlled in tests.
- File and Directory I/O are mockable or use temporary directories during testing.
- BuildContext is mockable for permission dialog testing.
- ViewModels, Repositories, and Services are testable in isolation without full app initialization.
- Tests do NOT require Firebase, network, or any external services.
- Tests focus on business logic correctness, not UI rendering or widget interaction.
- Coverage is measured using coverage tools (e.g., `flutter test --coverage`).
- The test suite is organized in `test/unit/` with files mirroring `lib/` structure (e.g., `test/unit/features/transaction/viewmodels/transaction_view_model_test.dart`).
- All mocked dependencies are injected via constructors or service locators; no global state or hard-coded dependencies.
- Tests run independently and can be executed in any order without side effects.
