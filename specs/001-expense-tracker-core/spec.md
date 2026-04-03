# Feature Specification: Expense Tracker — Ứng dụng quản lý chi tiêu cá nhân

**Feature Branch**: `001-expense-tracker-core`  
**Created**: 2026-04-03  
**Status**: Draft  
**Input**: User description: "Expense Tracker – Ứng dụng quản lý chi tiêu cá nhân"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Record a Transaction (Priority: P1)

A user opens the app and adds a new expense (e.g., lunch for 85,000 VND, category "Food"). The transaction is immediately saved and visible in the transaction list with correct amount, category, date, and type.

**Why this priority**: Recording transactions is the atomic unit of the entire app. Without it, no other feature has data to work with.

**Independent Test**: Can be fully tested by launching the app, tapping "Add Transaction", completing the form, and confirming the entry appears in the transaction list with correct values.

**Acceptance Scenarios**:

1. **Given** the transaction list is open, **When** the user taps "Add", fills in amount (85000), type (Expense), category (Food), date (today), note (optional), and confirms, **Then** the transaction appears at the top of the list with all entered values displayed correctly.
2. **Given** the add-transaction form is open, **When** the user submits with no amount, **Then** the form shows the error "Amount is required" and does not save.
3. **Given** the add-transaction form is open, **When** the user enters amount 0 or a negative number, **Then** the form shows "Amount must be greater than 0".
4. **Given** a saved transaction, **When** the user taps it and edits the amount, **Then** the updated value is reflected immediately in the list.
5. **Given** a saved transaction, **When** the user deletes it via the detail screen, **Then** it is removed from the list and totals are recalculated.

---

### User Story 2 — Manage Categories (Priority: P2)

A user creates a custom category "Gym", assigns a colour/icon to it, and uses it when recording a transaction.

**Why this priority**: Categories give transactions meaning and are required for reports and filtering.

**Independent Test**: Navigate to Settings → Categories, create a new category, then verify it appears in the category picker on the add-transaction form.

**Acceptance Scenarios**:

1. **Given** the category list is open, **When** the user creates category "Gym" with colour green, **Then** "Gym" appears in the category list and in the transaction form's category picker.
2. **Given** a category with existing transactions, **When** the user attempts to delete it, **Then** a confirmation dialog warns "X transactions use this category. Deleting it will set them to Uncategorized." The user confirms and deletion proceeds.
3. **Given** a category name that already exists, **When** the user tries to create it, **Then** the form shows "Category name already exists".
4. **Given** the category list, **When** the user edits a category name, **Then** all transactions previously linked to it reflect the updated name.

---

### User Story 3 — View Spending Reports (Priority: P3)

A user opens the Reports screen and views their total income, total expenses, and net balance for the current month, broken down by category.

**Why this priority**: Reports are the primary value-delivery feature — they make raw data actionable.

**Independent Test**: Add several transactions across multiple categories, navigate to Reports, select "Monthly" view, and verify totals match manual calculation.

**Acceptance Scenarios**:

1. **Given** transactions exist for the current month, **When** the user opens Reports → Monthly, **Then** they see: total income, total expenses, net balance (income − expenses), and a per-category breakdown.
2. **Given** the Reports screen, **When** the user switches between Daily / Weekly / Monthly tabs, **Then** the totals and groupings update to reflect the selected period.
3. **Given** no transactions in the selected period, **When** the user views Reports, **Then** an empty-state message is shown ("No transactions for this period") instead of zero-value charts.
4. **Given** more than 500 transactions in a period, **When** the report loads, **Then** it still displays within 1 second.

---

### User Story 4 — Search and Filter Transactions (Priority: P4)

A user filters transactions by date range (last 30 days), type (Expense), and category (Food) to review their food spending.

**Why this priority**: Filtering makes the transaction list useful once data volume grows beyond a few entries.

**Independent Test**: Add transactions across multiple categories and types, apply category + type filter, and verify only matching transactions are shown.

**Acceptance Scenarios**:

1. **Given** the transaction list, **When** the user applies filter: type=Expense AND category=Food, **Then** only expense transactions in the Food category are shown.
2. **Given** active filters, **When** the user searches keyword "coffee", **Then** results are further narrowed to transactions whose note contains "coffee".
3. **Given** active filters, **When** the user taps "Clear Filters", **Then** all transactions are shown again.
4. **Given** filters that match no transactions, **When** applied, **Then** an empty-state message is shown ("No transactions match your filters").

---

### User Story 5 — Export Transactions to CSV (Priority: P5)

A user saves all their transactions to a CSV file on their device storage and optionally shares it with another app (e.g., Numbers, Excel).

**Why this priority**: Export is a power-user feature valuable for external analysis; it does not block other stories.

**Independent Test**: Add 10 transactions, tap Save CSV, confirm the SnackBar shows the saved filename, open the file from the Files app (iOS) or a file manager (Android), and verify rows match the in-app list.

**Acceptance Scenarios**:

1. **Given** transactions exist, **When** the user taps the Save CSV button, **Then** a CSV file is saved to device storage and a SnackBar confirms the filename (e.g., `expense_tracker_2026-04-03_<timestamp>.csv`).
2. **Given** the save SnackBar is visible, **When** the user taps "Share", **Then** the OS share sheet opens so the file can be sent to another app or person.
3. **Given** active filters on the transaction list, **When** the user saves a CSV, **Then** only the filtered transactions are included in the CSV.
4. **Given** no transactions, **When** the user taps Save CSV, **Then** a message is shown: "Nothing to export — add some transactions first."
5. **Given** a generated CSV, **When** opened in a spreadsheet tool, **Then** columns match the defined schema (see CSV Export Format section).

---

### Edge Cases

- **Empty dataset**: All list screens show a friendly empty-state illustration with a prompt to add the first transaction.
- **Delete category with linked transactions**: Transactions are reassigned to "Uncategorized" (a built-in, non-deletable category). The category total in reports reflects this reassignment.
- **Large dataset (> 1,000 transactions)**: Lists MUST use lazy/paginated loading (page size: 50). Reports MUST use aggregated DB queries, not in-memory iteration.
- **Duplicate transaction**: Not blocked at the data layer (same amount + category + date is valid). Users are responsible for entry accuracy.
- **Invalid date**: Dates in the future are allowed (scheduled entries). Dates before 1970-01-01 are rejected.
- **Amount precision**: Amounts are stored as integer minor units (e.g., VND as whole number, USD in cents). Display formatting is locale-aware.

---

## Requirements *(mandatory)*

### Functional Requirements

#### Transactions

| ID | Requirement |
|----|-------------|
| FR-001 | System MUST allow users to create a transaction with: amount, type (income/expense), category, date, and optional note. |
| FR-002 | System MUST allow users to edit any field of an existing transaction. |
| FR-003 | System MUST allow users to delete a transaction after confirming the action. |
| FR-004 | System MUST display the transaction list sorted by date descending by default. |
| FR-005 | System MUST paginate the transaction list (50 items per page / lazy load). |
| FR-006 | System MUST recalculate report totals immediately after any create/edit/delete. |

#### Categories

| ID | Requirement |
|----|-------------|
| FR-007 | System MUST provide default categories: Food, Transport, Shopping, Health, Entertainment, Bills, Income, Other. |
| FR-008 | Users MUST be able to create custom categories with a name and optional icon/colour. |
| FR-009 | Users MUST be able to rename and delete custom categories. |
| FR-010 | Deleting a category MUST reassign its transactions to "Uncategorized". |
| FR-011 | "Uncategorized" MUST be a built-in category that cannot be deleted or renamed. |

#### Reports

| ID | Requirement |
|----|-------------|
| FR-012 | System MUST provide a report view with Daily, Weekly, and Monthly period selectors. |
| FR-013 | Each report period MUST show: total income, total expenses, net balance. |
| FR-014 | Each report period MUST show a category breakdown (category name, total amount, percentage of total expenses). |
| FR-015 | Report queries MUST complete in < 500 ms for up to 1,000 transactions. |

#### Filtering & Search

| ID | Requirement |
|----|-------------|
| FR-016 | Users MUST be able to filter the transaction list by: date range, transaction type, category, and amount range. |
| FR-017 | All filters MUST be combinable (AND logic between filters). |
| FR-018 | Users MUST be able to search transactions by keyword (matched against the note field). |
| FR-019 | Clearing all filters MUST restore the full unfiltered list. |

#### Export

| ID | Requirement |
|----|-------------|
| FR-020 | Users MUST be able to save a CSV file of their transactions directly to device storage. |
| FR-021 | After saving, the app MUST display a SnackBar confirming the filename with an optional "Share" action to open the OS share sheet. |
| FR-022 | Export MUST respect currently active filters (export filtered subset, or all if no filters). |
| FR-023a | On Android, the CSV MUST be saved to app-specific external storage (visible in file manager apps, no runtime permission needed on API 29+). |
| FR-023b | On iOS, the CSV MUST be saved to the app Documents directory (accessible via the Files app). |
| FR-024a | Exported file MUST be named `expense_tracker_YYYY-MM-DD_<timestamp>.csv` using the export date and a unique timestamp. |

#### Navigation

| ID | Requirement |
|----|-------------|
| FR-023 | The app MUST launch directly on the Reports screen as the primary home view. |
| FR-024 | The Reports screen MUST be the first tab in the bottom navigation bar, displaying the current-month summary and category breakdown without additional navigation. |
| FR-025 | The "Add Transaction" action MUST be reachable in ≤ 2 taps from any screen. |

---

### Key Entities

#### Transaction

| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| `id` | integer (PK, auto-increment) | Yes | — | `42` |
| `amount` | integer (minor currency units) | Yes | > 0 | `85000` (85,000 VND) |
| `type` | enum: `income` \| `expense` | Yes | Must be one of the enum values | `"expense"` |
| `category_id` | integer (FK → Category.id) | Yes | Must reference an existing category | `3` |
| `date` | ISO 8601 date string `YYYY-MM-DD` | Yes | Valid date ≥ 1970-01-01 | `"2026-04-03"` |
| `note` | string, max 500 chars | No | — | `"Lunch at café"` |
| `created_at` | ISO 8601 datetime | Yes (system-set) | — | `"2026-04-03T08:30:00Z"` |
| `updated_at` | ISO 8601 datetime | Yes (system-set) | — | `"2026-04-03T08:30:00Z"` |

#### Category

| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| `id` | integer (PK, auto-increment) | Yes | — | `1` |
| `name` | string, max 100 chars | Yes | Non-empty, unique | `"Food"` |
| `icon` | string (icon identifier) | No | — | `"restaurant"` |
| `colour` | string (hex colour) | No | Valid hex `#RRGGBB` | `"#FF5733"` |
| `is_system` | boolean | Yes (system-set) | — | `true` (for built-in categories) |
| `created_at` | ISO 8601 datetime | Yes (system-set) | — | `"2026-04-01T00:00:00Z"` |
| `updated_at` | ISO 8601 datetime | Yes (system-set) | — | `"2026-04-01T00:00:00Z"` |

**Relationships**: `Transaction.category_id` → `Category.id` (many-to-one). One category can have many transactions.

---

### API / Service Contract

> Because this is a local-first Flutter app with no backend, these contracts describe the **repository interface** (Domain layer). Platform teams implementing a backend in the future MUST honour these signatures.

#### Transactions

| Operation | Method / Signature | Parameters | Returns |
|-----------|-------------------|------------|---------|
| Create | `createTransaction(TransactionInput)` | amount, type, categoryId, date, note? | `Transaction` |
| Update | `updateTransaction(id, TransactionInput)` | all editable fields | `Transaction` |
| Delete | `deleteTransaction(id)` | transaction id | `void` |
| List | `getTransactions(filters?, page, pageSize)` | dateFrom?, dateTo?, type?, categoryId?, amountMin?, amountMax?, keyword?, page=1, pageSize=50 | `PaginatedResult<Transaction>` |

#### Categories

| Operation | Method / Signature | Parameters | Returns |
|-----------|-------------------|------------|---------|
| Create | `createCategory(CategoryInput)` | name, icon?, colour? | `Category` |
| Update | `updateCategory(id, CategoryInput)` | name?, icon?, colour? | `Category` |
| Delete | `deleteCategory(id)` | category id (must not be system) | `void` |
| List | `getCategories()` | — | `List<Category>` |

#### Reports

| Operation | Method / Signature | Parameters | Returns |
|-----------|-------------------|------------|---------|
| Summary | `getReportSummary(period, referenceDate)` | period: `daily`\|`weekly`\|`monthly`, referenceDate | `ReportSummary` |
| Category Breakdown | `getCategoryBreakdown(period, referenceDate)` | same as above | `List<CategoryBreakdown>` |

`ReportSummary` shape:
```
{ totalIncome: int, totalExpenses: int, netBalance: int, periodLabel: string }
```

`CategoryBreakdown` shape:
```
{ categoryId: int, categoryName: string, total: int, percentage: double }
```

#### Export

| Operation | Method / Signature | Parameters | Returns |
|-----------|-------------------|------------|---------|
| Export CSV | `exportToCsv(filters?)` | same filter set as List | `String` — absolute path of the saved CSV file |

---

### Filtering & Search — Supported Filters

| Filter | Type | Behaviour |
|--------|------|-----------|
| `dateFrom` | `YYYY-MM-DD` | Transactions on or after this date |
| `dateTo` | `YYYY-MM-DD` | Transactions on or before this date |
| `type` | `income` \| `expense` | Exact match |
| `categoryId` | integer | Exact match |
| `amountMin` | integer (minor units) | Transactions ≥ this amount |
| `amountMax` | integer (minor units) | Transactions ≤ this amount |
| `keyword` | string | Case-insensitive substring match against `note` field |

All filters are optional. Multiple filters combine with AND logic.

---

### Dashboard & Reporting Logic

**Totals calculation**:
- `totalIncome` = SUM of `amount` WHERE `type = 'income'` in the selected period.
- `totalExpenses` = SUM of `amount` WHERE `type = 'expense'` in the selected period.
- `netBalance` = `totalIncome − totalExpenses`.

**Period boundaries**:
- **Daily**: 00:00:00 – 23:59:59 of the reference date.
- **Weekly**: Monday 00:00:00 – Sunday 23:59:59 of the week containing the reference date (ISO week).
- **Monthly**: 1st 00:00:00 – last-day 23:59:59 of the month containing the reference date.

**Category breakdown**:
- Calculated over expense transactions only (income shown as a single total).
- `percentage` = `(categoryTotal / totalExpenses) × 100`, rounded to 1 decimal place.
- Categories with 0 expense transactions in the period are omitted from the breakdown.

**Edge cases**:
- Period with no transactions → return `{ totalIncome: 0, totalExpenses: 0, netBalance: 0 }` and empty breakdown list.
- Single category with 100% of expenses → `percentage = 100.0`.

---

### CSV Export Format

**Columns** (in order):

| Column | Source Field | Format |
|--------|-------------|--------|
| `Date` | `transaction.date` | `YYYY-MM-DD` |
| `Type` | `transaction.type` | `income` or `expense` |
| `Amount` | `transaction.amount` | Integer (minor currency units), no decimal for VND; divide by 100 for currencies with cents |
| `Currency` | app setting | e.g., `VND` |
| `Category` | `category.name` | As stored |
| `Note` | `transaction.note` | Empty string if null |
| `Created At` | `transaction.created_at` | ISO 8601 `YYYY-MM-DDTHH:MM:SSZ` |

**File naming**: `expense_tracker_YYYY-MM-DD_<unix-ms>.csv` where the date is the export date and the timestamp suffix guarantees uniqueness.

**Save location**:
- **Android**: `getExternalStorageDirectory()` (e.g. `/storage/emulated/0/Android/data/<package>/files/`); no runtime permission required on API 29+. Adds `WRITE_EXTERNAL_STORAGE` permission with `maxSdkVersion="28"` for Android ≤ 9 in `AndroidManifest.xml`.
- **iOS**: `getApplicationDocumentsDirectory()`; exposed to the Files app via `UIFileSharingEnabled = true` and `LSSupportsOpeningDocumentsInPlace = true` in `Info.plist`.

**Share**: After a successful save, the UI shows a SnackBar with the filename and an optional "Share" action that invokes `Share.shareXFiles([XFile(path)])` (share_plus).

**Header row**: Always included, even for empty exports.

**Encoding**: UTF-8 with BOM (ensures correct display in Excel for non-ASCII characters, e.g., Vietnamese).

**Delimiter**: Comma (`,`). Fields containing commas or newlines MUST be quoted.

**Example CSV**:
```
Date,Type,Amount,Currency,Category,Note,Created At
2026-04-03,expense,85000,VND,Food,Lunch at café,2026-04-03T08:30:00Z
2026-04-02,income,5000000,VND,Income,Monthly salary,2026-04-02T09:00:00Z
```

---

### Validation Rules

| Field | Rule | Error Message |
|-------|------|---------------|
| `amount` | Required, integer > 0 | "Amount is required" / "Amount must be greater than 0" |
| `type` | Required, one of `income`/`expense` | "Transaction type is required" |
| `categoryId` | Required, must reference an existing category | "Please select a category" |
| `date` | Required, valid date ≥ 1970-01-01 | "Please enter a valid date" |
| `note` | Optional, max 500 characters | "Note cannot exceed 500 characters" |
| `category.name` | Required, non-empty, max 100 chars, unique | "Category name is required" / "Category name already exists" |
| `category.colour` | Optional, must be valid `#RRGGBB` hex | "Enter a valid colour code (e.g. #FF5733)" |
| Delete system category | Not allowed | "Built-in categories cannot be deleted" |
| Date range filter | `dateFrom` ≤ `dateTo` if both provided | "End date must be after start date" |
| Amount range filter | `amountMin` ≤ `amountMax` if both provided | "Maximum amount must be greater than minimum" |

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

| ID | Criterion |
|----|-----------|
| SC-001 | A user can add a transaction (amount, type, category, date) in under 30 seconds from any screen. |
| SC-002 | The transaction list with 1,000 records loads and scrolls without perceptible lag (< 200 ms initial render). |
| SC-003 | Report summary for any period loads in under 500 ms with up to 1,000 transactions. |
| SC-004 | A CSV export of 500 transactions is saved to device storage and confirmed via SnackBar in under 3 seconds. |
| SC-005 | The app reaches a usable state (Reports screen visible with current-month summary) in under 2 seconds on a mid-range device (cold start). |
| SC-006 | 100% of validation errors are communicated to the user inline (no silent failures). |
| SC-007 | Report totals are always consistent with the raw transaction data — no stale state after create/edit/delete. |
| SC-008 | All confirmed 5 features are demonstrable end-to-end without requiring a backend or internet connection. |

---

## Assumptions

- **Single-user system**: No authentication, no user accounts, no multi-user data isolation required for this spec.
- **Local storage only**: All data lives on-device. No backend API or cloud database is used by the MVP.
- **Currency**: The app defaults to VND (Vietnamese Dong) with no decimal places. Currency is configurable in Settings as a future patch; the data model (integer minor units) already supports multi-currency without schema changes.
- **Device platform**: Primary target is iOS and Android via Flutter. Web/desktop are explicitly out of scope for MVP.
- **No offline-sync requirement**: Because the app is always local, there is no sync conflict scenario.
- **Date/time**: All dates stored as `YYYY-MM-DD`; no time-zone conversion is required for a single-user local app. `created_at`/`updated_at` stored in device local time as ISO 8601.
- **Category icons**: Sourced from the Material Icons set already bundled with Flutter — no custom icon upload required.
- **Performance baseline**: A mid-range Android device (2–3 GB RAM, 2019–2021) is the minimum performance target.
- **Data retention**: No automatic data deletion. All transactions are retained until the user manually deletes them. No legal/regulatory data retention requirements apply to this MVP.
