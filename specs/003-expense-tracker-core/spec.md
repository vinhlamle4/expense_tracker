# Feature Specification: Expense Tracker Core Features

**Feature Branch**: `003-expense-tracker-core`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "Transaction management, Category classification, Dashboard with charts, Search & Filter, Light/Dark mode toggle, CSV export"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Transaction Management (Priority: P1)

A user wants to record their daily spending and income. They open the app, tap "Add Transaction", fill in the amount, select a date, choose whether it is income or expense, optionally add a note, and save. The new entry appears immediately in the transaction list and the Dashboard totals update automatically. The user can later tap any transaction to edit its details or swipe to delete it.

**Why this priority**: Without the ability to create, read, update, and delete transactions, the app has no data to work with. Every other feature depends on transactions existing.

**Independent Test**: Can be fully tested by adding several transactions, verifying they appear in the list with correct details, editing one and confirming the change persists, and deleting one and confirming it disappears — without needing charts, search, or export.

**Acceptance Scenarios**:

1. **Given** the app is open and the transaction list is empty, **When** the user taps "Add Transaction", fills in amount 150,000, selects today's date, selects "Expense", adds note "Coffee", and saves, **Then** the transaction appears in the list with the correct details and the Dashboard Expense total increases by 150,000.
2. **Given** an existing transaction is displayed, **When** the user opens it and changes the amount to 200,000 and saves, **Then** the transaction shows 200,000 and all Dashboard totals are recalculated.
3. **Given** an existing transaction is displayed, **When** the user deletes it, **Then** it is removed from the list and Dashboard totals are recalculated immediately.
4. **Given** the user is on the Add Transaction screen, **When** they try to save with no amount entered, **Then** a validation message is shown and the transaction is not saved.

---

### User Story 2 - Category Classification (Priority: P2)

A user wants to understand where their money goes. When adding or editing a transaction, they can assign it to a category such as "Food & Drink", "Transport", "Salary", or "Entertainment". Categories have an icon and are scoped to income or expense types. The app provides a default set of categories, and the user can also create custom ones.

**Why this priority**: Categories give context to raw transactions and are required for meaningful Dashboard breakdowns and filtering. They add significant value but can rely on a default set, making this independently deliverable after P1.

**Independent Test**: Can be tested by creating transactions with different categories, verifying the category is saved and displayed correctly on the transaction detail, and confirming that category-based grouping appears without requiring charts or export.

**Acceptance Scenarios**:

1. **Given** the user is adding a transaction, **When** they tap the Category field, **Then** a list of default categories appropriate to the selected type (income/expense) is displayed.
2. **Given** a category list is shown, **When** the user selects "Food & Drink" and saves the transaction, **Then** the transaction is tagged with "Food & Drink" and the category name is visible in the transaction list.
3. **Given** no suitable default category exists, **When** the user creates a custom category "Freelance" with an icon, **Then** "Freelance" appears in the income category list and can be assigned to transactions.
4. **Given** a category is assigned to one or more transactions, **When** the user attempts to delete that category, **Then** the app warns that existing transactions will be moved to "Uncategorized" and proceeds only after confirmation.

---

### User Story 3 - Dashboard with Charts (Priority: P3)

A user wants a visual overview of their financial health. The Dashboard screen shows the current Balance, Total Income, and Total Expense for the selected period, along with a chart (bar or pie) breaking down spending or income by category. The user can switch the view between Day, Week, and Month periods.

**Why this priority**: The Dashboard is the primary value-delivery screen, but it depends on transactions and categories existing. A meaningful chart requires both P1 and P2 to be complete.

**Independent Test**: Can be tested by pre-seeding transactions across different categories and periods, then verifying the Dashboard totals and chart segments match the expected values for each period selection.

**Acceptance Scenarios**:

1. **Given** transactions exist for the current month, **When** the user opens the Dashboard, **Then** Balance, Total Income, and Total Expense reflect the sum of all transactions in the current month.
2. **Given** the Dashboard is showing the monthly view, **When** the user switches to "Week", **Then** all figures and chart data update to reflect only the current week's transactions.
3. **Given** a new transaction is created on the Transaction screen, **When** the user navigates back to the Dashboard, **Then** the totals and chart update immediately to include the new transaction.
4. **Given** no transactions exist for the selected period, **When** the Dashboard is displayed, **Then** an empty state is shown with a prompt to add a transaction; Balance, Income, and Expense all display zero.

---

### User Story 4 - Search & Filter (Priority: P4)

A user wants to find a specific past transaction. They can type into a search bar to instantly filter the transaction list by note text. They can also apply filters: a date range picker to narrow results to a specific interval and a category selector to show only transactions in a chosen category. Filters can be combined.

**Why this priority**: Search and filter improve usability as the transaction list grows. This feature adds discovery value on top of the core list and is independently testable without affecting data integrity.

**Independent Test**: Can be tested by adding transactions with different notes, dates, and categories, then verifying that search by note text, filter by date range, and filter by category each return the correct subset — independently and in combination.

**Acceptance Scenarios**:

1. **Given** the transaction list has entries with notes "Coffee", "Taxi", and "Salary", **When** the user types "Cof" in the search bar, **Then** only the "Coffee" transaction is shown.
2. **Given** transactions span multiple months, **When** the user sets a date range filter for the current month, **Then** only transactions within that range are displayed.
3. **Given** transactions belong to multiple categories, **When** the user filters by "Transport", **Then** only transactions tagged "Transport" appear.
4. **Given** an active search term "Coffee" and an active category filter "Food & Drink", **When** both are applied simultaneously, **Then** only transactions matching both conditions are shown.
5. **Given** a filter is active, **When** the user clears all filters, **Then** the full unfiltered transaction list is restored.

---

### User Story 5 - Light/Dark Mode Toggle (Priority: P5)

A user prefers to use the app at night in Dark mode. They open Settings, toggle the theme to "Dark", and the entire app immediately switches to dark colors. The next time they open the app, it remembers and starts in Dark mode. They can also choose "System" to follow the device's current setting.

**Why this priority**: Theme preference is a personalization feature that does not affect core data or reporting. It can be delivered independently once the UI exists.

**Independent Test**: Can be tested by toggling the theme mode between Light, Dark, and System, verifying the UI color scheme changes immediately, closing and reopening the app, and confirming the previously selected mode is applied on launch.

**Acceptance Scenarios**:

1. **Given** the app is in Light mode, **When** the user selects "Dark" in Settings, **Then** the entire app switches to dark color scheme immediately without requiring a restart.
2. **Given** the app is in Dark mode, **When** the app is closed and reopened, **Then** it opens in Dark mode, not the default Light mode.
3. **Given** the user selects "System" mode, **When** the device switches between light and dark at the OS level, **Then** the app follows the device's current setting.

---

### User Story 6 - CSV Export (Priority: P6)

A user wants to back up or analyze their data in a spreadsheet. They navigate to the Export section, tap "Export to CSV", and the app generates a CSV file containing all transactions (or those matching active filters) and saves it to the device's local storage. A confirmation message shows the file path.

**Why this priority**: CSV export is a convenience feature for data portability. It delivers standalone value without impacting any other user story.

**Independent Test**: Can be tested by adding transactions and triggering the export, then verifying the generated CSV file exists on device storage, contains the correct columns and row count, and can be opened in a spreadsheet app.

**Acceptance Scenarios**:

1. **Given** 50 transactions exist, **When** the user taps "Export to CSV", **Then** a CSV file is saved to the device's Documents folder containing 50 data rows plus a header row with columns: Date, Type, Category, Amount, Note.
2. **Given** an active category filter for "Food & Drink" is applied, **When** the user exports, **Then** the CSV contains only transactions in that category.
3. **Given** the export completes successfully, **When** the user views the confirmation, **Then** the full file path is displayed and the file is accessible via the device's file manager.
4. **Given** the device has insufficient storage, **When** export is attempted, **Then** a user-friendly error message is displayed and no partial file is left on disk.

---

### Edge Cases

- What happens when a user enters 0 as the transaction amount? (Validation must reject zero-amount transactions.)
- What happens when the amount field is left blank or contains non-numeric characters?
- How does the Dashboard chart render when all transactions belong to a single category?
- What happens when a category referenced by existing transactions is deleted?
- How does the app behave when the transaction list exceeds 1,000 entries — does scrolling and search remain responsive?
- What happens if the user tries to export while no transactions exist? (Export produces a header-only CSV or shows an informative message.)
- What happens when the date range filter has a start date later than the end date?
- How does the weekly chart display when the week spans two different months?
- How does the system mode behave on devices that do not support dark mode at the OS level?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Users MUST be able to create a transaction by providing: amount (positive number), date, type (Income or Expense), optional note, and a category.
- **FR-002**: Users MUST be able to edit any field of an existing transaction and save the changes.
- **FR-003**: Users MUST be able to delete a transaction, with a confirmation prompt before permanent removal.
- **FR-004**: The system MUST validate that transaction amount is a positive, non-zero number before saving; invalid submissions MUST display a descriptive error message.
- **FR-005**: The Dashboard MUST automatically display the current period's Balance (Income minus Expense), Total Income, and Total Expense without requiring a manual refresh.
- **FR-006**: The Dashboard MUST update all totals and charts immediately after any transaction is created, edited, or deleted.
- **FR-007**: The Dashboard MUST support period switching between Day, Week, and Month views.
- **FR-008**: The Dashboard MUST display a chart (bar or pie) breaking down amounts by category for the selected period.
- **FR-009**: The system MUST provide a default set of categories for both Income and Expense types.
- **FR-010**: Users MUST be able to create custom categories with a name and an icon.
- **FR-011**: Users MUST be able to assign exactly one category to each transaction.
- **FR-012**: When a category is deleted, the system MUST reassign affected transactions to an "Uncategorized" placeholder and warn the user before proceeding.
- **FR-013**: Users MUST be able to search transactions by note text with results updating as the user types.
- **FR-014**: Users MUST be able to filter transactions by a date range (start date to end date).
- **FR-015**: Users MUST be able to filter transactions by one or more categories.
- **FR-016**: Search and filter criteria MUST be combinable; all active criteria apply simultaneously.
- **FR-017**: Users MUST be able to clear all active search/filter criteria to restore the full transaction list.
- **FR-018**: Users MUST be able to select a theme mode from: Light, Dark, or System.
- **FR-019**: The selected theme mode MUST be persisted to local storage and applied on every subsequent app launch before the first screen renders (no visible flicker).
- **FR-020**: Users MUST be able to export all transactions (or the currently filtered subset) to a CSV file saved to the device's local Documents folder.
- **FR-021**: The exported CSV MUST include a header row and the following columns per transaction: Date, Type, Category, Amount, Note.
- **FR-022**: The system MUST display the saved file path upon successful export and show a user-friendly error if export fails.
- **FR-023**: The app MUST function fully without any network connectivity; no feature may require an internet connection.

### Key Entities

- **Transaction**: Represents a single financial event. Key attributes: unique identifier, monetary amount, date, type (Income or Expense), optional note, and a reference to one category.
- **Category**: Represents a named group for classifying transactions. Key attributes: unique identifier, display name, icon reference, and applicable type scope (Income, Expense, or Both).
- **AppSettings**: Represents user preferences stored locally. Key attributes: selected theme mode (Light, Dark, or System). Exactly one settings record exists per installation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a complete transaction (amount, date, type, category, note) in under 30 seconds from tapping "Add" to seeing it in the list.
- **SC-002**: The Dashboard totals and chart update within 1 second of a transaction being created, edited, or deleted — without requiring navigation away and back.
- **SC-003**: The app launches and displays the previously selected theme mode (Light/Dark/System) before the first screen is visible; no white-flash or theme switch is observable after the splash.
- **SC-004**: The app remains fully functional — all six user stories operational — with no network connection present.
- **SC-005**: The transaction list scrolls without perceptible lag for lists of up to 1,000 entries; search results appear within 500 milliseconds of the user finishing typing.
- **SC-006**: CSV export completes and a confirmation is shown within 5 seconds for up to 1,000 transactions.
- **SC-007**: 90% of first-time users can add their first transaction successfully without consulting documentation (task-completion rate on primary flow).

## Assumptions

- The app is single-user and single-device; there is no account system, login, or cloud sync.
- The default currency is Vietnamese Dong (VND); currency selection is out of scope for this version.
- A fixed set of default categories (e.g., Food & Drink, Transport, Shopping, Healthcare, Salary, Other Income) is pre-populated on first launch.
- Transactions without an explicitly assigned category are automatically placed under "Uncategorized".
- The CSV export targets the device's standard Documents directory; no custom path selection is required.
- On Android, the app requests storage write permission at the time of the first export; the permission UX follows OS-standard patterns.
- No transaction amount limits are enforced beyond the constraint that amount must be a positive number.
- Date range for a transaction is a single calendar date (not a date-time), and the app uses the device's local timezone.
- "System" theme mode inherits the OS-level dark/light preference; on devices where OS dark mode is unavailable, System falls back to Light.
- Charts display the selected period relative to the current device date (e.g., "Month" always means the current calendar month unless the user navigates).
