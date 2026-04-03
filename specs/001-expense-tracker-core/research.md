# Research: Expense Tracker — 001-expense-tracker-core

**Generated**: 2026-04-03 | **Phase**: 0

All unknowns identified in the Technical Context have been resolved below.
Zero `[NEEDS CLARIFICATION]` markers remain.

---

## Decision 1: State Management — Riverpod

- **Decision**: Use `flutter_riverpod` (Riverpod 2.x) as the sole state management solution.
- **Rationale**:
  - Compile-time safety: providers are typed and caught at analysis time, not runtime.
  - Excellent separation between domain logic and UI — providers can reference use-cases directly without widget coupling.
  - First-class support for async data (`AsyncValue`) maps cleanly to loading/error/data states required by constitution UX rule.
  - No `BuildContext` wiring needed for reading providers from domain layer.
- **Alternatives considered**:
  - `bloc`: More boilerplate per feature; well-suited for large teams but heavy for a solo/small MVP.
  - `provider` (legacy): Superseded by Riverpod; less type-safe.
  - `setState` / `InheritedWidget`: Insufficient for cross-feature shared state (e.g., dashboard re-computing after a transaction is added from a deep navigation route).

---

## Decision 2: Local Database — sqflite with manual migrations

- **Decision**: Use `sqflite` with a hand-authored migration system (version table, sequential migration scripts).
- **Rationale**:
  - Native SQLite bindings; mature, widely used in Flutter ecosystem.
  - SQL `GROUP BY` and `SUM` aggregations run on the DB layer — mandatory for the ≤ 500 ms report performance goal.
  - Full control over schema without code generation (keeps the dependency graph lean for MVP).
  - Pagination via `LIMIT` / `OFFSET` is straightforward.
- **Alternatives considered**:
  - `drift` (formerly Moor): Type-safe query builder with code generation. Preferred for long-term projects but adds build_runner complexity unsuitable for a fast MVP.
  - `hive` / `isar`: NoSQL, not relational — `JOIN`-style category breakdown queries would require in-memory aggregation, risking the performance target.
  - `shared_preferences`: Only for scalar key-value settings (currency label), not for transactional data.

---

## Decision 3: Routing — go_router

- **Decision**: Use `go_router` for declarative routing.
- **Rationale**:
  - Official Flutter team package; stable and aligned with Navigator 2.0.
  - Named routes simplify deep-linking and the "≤ 2 taps" navigation requirement.
  - Shell routes allow bottom navigation without rebuilding all screens.
- **Alternatives considered**:
  - `auto_route`: More code generation overhead; overkill for 5 screens.
  - Raw `Navigator.push`: Imperative, harder to test navigation flows.

---

## Decision 4: Charts Library — fl_chart

- **Decision**: Use `fl_chart` for the category breakdown bar/pie chart in reports.
- **Rationale**:
  - No external dependencies; renders to Flutter canvas (fully offline, no WebView).
  - Supports bar charts and pie charts; both are suitable for category breakdown.
  - Actively maintained on pub.dev (verified as of April 2026).
- **Alternatives considered**:
  - `syncfusion_flutter_charts`: Commercial license required for production use.
  - `charts_flutter`: Archived by Google, no longer maintained.
  - Plain `CustomPainter`: Maximum control but requires significant implementation effort for MVP.

---

## Decision 5: CSV Generation — csv package + manual UTF-8 BOM

- **Decision**: Use the `csv` Dart package to serialise rows; prepend UTF-8 BOM (`\uFEFF`) manually before writing to file.
- **Rationale**:
  - The `csv` package handles comma-quoting and newline escaping correctly with minimal code.
  - UTF-8 BOM is required for Vietnamese characters to display correctly when opened in Microsoft Excel on Windows.
  - `path_provider` + `share_plus` handle file creation and the OS share sheet.
- **Alternatives considered**:
  - Manual string building: Fragile for edge cases (notes containing commas or newlines); error-prone.
  - Server-side generation: Out of scope per constitution MVP constraints.

---

## Decision 6: Monetary Amount Representation — integer minor units

- **Decision**: Store and compute all monetary amounts as integers in the smallest currency unit (VND = whole đồng; USD = cents). Display only via `CurrencyFormatter` utility.
- **Rationale**:
  - Eliminates floating-point rounding errors entirely (e.g., 0.1 + 0.2 ≠ 0.3 in IEEE 754).
  - VND has no sub-unit, so `int` maps directly to the value shown to users.
  - Future multi-currency support (e.g., USD at cents) requires no schema change.
- **Alternatives considered**:
  - `double`: Common source of display/calculation bugs in financial apps; rejected by constitution Data Modeling Rules.
  - `Decimal` package: Correct but adds a dependency; unnecessary when `int` fully covers the use-case.

---

## Decision 7: Date Handling — local date strings (YYYY-MM-DD)

- **Decision**: Store the user-entered transaction date as an ISO 8601 date string (`YYYY-MM-DD`). Store `created_at` / `updated_at` as ISO 8601 datetime in device local time.
- **Rationale**:
  - Single-user local app with no server sync — no time-zone conversion is ever needed.
  - Date string comparison (`WHERE date >= ? AND date <= ?`) works correctly with the `YYYY-MM-DD` lexicographic order in SQLite.
  - Avoids Unix timestamp ↔ `DateTime` conversion errors across DST boundaries.
- **Alternatives considered**:
  - Unix timestamps: Correct but adds conversion boilerplate throughout the codebase; no benefit without a UTC server.
  - `DateTime` stored as ISO string with time: Unnecessary precision for a date-only user field.

---

## Decision 8: Testing Approach — flutter_test + integration_test

- **Decision**: Unit and widget tests via `flutter_test`; smoke/integration tests via `integration_test` run on device/emulator.
- **Rationale**:
  - Both packages are bundled with the Flutter SDK — zero extra dependencies.
  - `integration_test` smoke flows drive the real app on a real SQLite DB, catching issues that mock-based tests miss.
  - Mocking the repository interface (not SQLite directly) keeps unit tests fast and deterministic.
- **Alternatives considered**:
  - `mockito` / `mocktail`: Either is acceptable for generating mocks; `mocktail` preferred (no code generation, simpler setup).
  - BDD frameworks (`flutter_gherkin`): Excessive for MVP; Gherkin scenarios from spec can be mapped manually.

---

## Resolved Unknowns Summary

| Unknown | Resolution |
|---------|-----------|
| State management approach | Riverpod 2.x |
| Database library | sqflite + manual migrations |
| Router | go_router |
| Charts | fl_chart |
| CSV generation | `csv` package + BOM header |
| Money representation | `int` minor units |
| Date representation | `YYYY-MM-DD` string |
| Test framework | `flutter_test` + `integration_test` + `mocktail` |

All `NEEDS CLARIFICATION` items from the Technical Context are resolved.
**Phase 0 complete — proceed to Phase 1.**
