<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0 (MINOR — new sections added; existing principles enriched)
Modified principles:
  - I.  Feature Modularity       → expanded with confirmed product feature list
  - II. Local-First Data         → unchanged
  - III. Clean Architecture      → unchanged
  - IV. Test Coverage            → unchanged
  - V.  Simplicity & YAGNI       → updated to reference single-user MVP constraint
Added sections:
  - Product Scope (feature list)
  - Data Modeling Rules
  - Requirements Standards
  - MVP Constraints
Removed sections: none
Templates requiring updates:
  - .specify/templates/plan-template.md       ✅ no breaking conflicts detected
  - .specify/templates/spec-template.md       ✅ — spec authors must add Data Modeling
                                                  checklist per new section
  - .specify/templates/tasks-template.md      ✅ no breaking conflicts detected
  - .specify/templates/agent-file-template.md ✅ no breaking conflicts detected
Deferred TODOs: none
-->

# Expense Tracker Constitution

> **Role context**: Specifications for this project are authored from the perspective of an expert
> product architect and full-stack engineer specializing in scalable, user-friendly financial
> applications. All decisions MUST prioritize clarity, completeness, and practicality over
> theoretical elegance.

## Product Scope

The application is a **single-user personal Expense Tracker**. The confirmed feature set is:

| # | Feature | Description |
|---|---------|-------------|
| 1 | Transaction Recording | Add, edit, delete income and expense entries |
| 2 | Categorization | Assign each transaction to a predefined or custom category |
| 3 | Spending Reports | View aggregated summaries by day, week, and month |
| 4 | Search & Filter | Find transactions by date range, category, type, or keyword |
| 5 | CSV Export | Export all or filtered transactions to a CSV file |

Any feature not in the table above is OUT OF SCOPE unless a formal amendment is made.
Future extensibility targets (not in scope now): multi-currency, budgeting, cloud sync.

## Core Principles

### I. Feature Modularity

Each confirmed product feature MUST be developed as a self-contained module with its own
widgets, use-cases, and data access layer. No module may directly import the internals of
another; cross-module communication MUST go through shared interfaces or a service layer.

**Covers**: transactions, categories, reports, search/filter, CSV export, settings.

**Rationale**: Modularity keeps the codebase navigable and lets features be added or removed
without cascading breakage.

### II. Local-First Data & Privacy

All expense data MUST be persisted on-device (`sqflite` for relational data,
`shared_preferences` for settings only). No user financial data is transmitted to any remote
server unless the user explicitly opts in and the feature is clearly labelled.
Sensitive fields (amounts, notes) MUST NOT appear unredacted in logs.

**Rationale**: Personal financial data is sensitive. Local-first is the safest default and the
correct choice for a single-user MVP.

### III. Clean Architecture (NON-NEGOTIABLE)

Code MUST be organised into three layers:
- **Presentation**: Flutter widgets and state management (UI only, no business logic).
- **Domain**: Entities, use-cases, repository interfaces. Pure Dart — no Flutter imports.
- **Data**: Repository implementations, data sources, ORM/DAO models.

Dependencies MUST point inward — Presentation → Domain ← Data. The Domain layer MUST have
zero knowledge of Flutter or any storage technology.

**Rationale**: Each layer is independently testable. Violations here compound over time and
are the leading cause of unmaintainable Flutter codebases.

### IV. Test Coverage

Every feature MUST ship with passing tests before being considered done:
- **Unit tests**: all use-cases, domain entities, and repository logic.
- **Widget tests**: all primary screens (transaction list, add/edit form, report screen).
- **Smoke/integration tests**: critical flows — add transaction, filter list, view monthly report,
  export CSV.

`flutter test` MUST return exit code 0 before any feature is merged.

### V. Simplicity & YAGNI

Implement the simplest solution that correctly satisfies the confirmed requirement.
Over-engineering, pre-optimisation, and speculative abstractions are **prohibited**.
Unconfirmed requirements MUST NOT be implemented. Infrastructure MUST remain MVP-grade
(suitable for a single-user app without a dedicated backend).

**Rationale**: Avoids scope creep and keeps the codebase approachable. Complexity MUST be
justified with a documented trade-off.

## Data Modeling Rules

These rules apply to all core entities (Transaction, Category, etc.):

- Use **normalized relational structures** in SQLite. Denormalization MUST be justified.
- Every core entity MUST include: `id` (integer PK), `created_at` (ISO 8601 datetime),
  `updated_at` (ISO 8601 datetime).
- All field types MUST be explicit — no dynamic or `Object` types.
- Enums MUST be defined with a finite set of values and stored as strings in the DB.
  Key enums:
  - `TransactionType`: `income` | `expense`
  - `ExportFormat`: `csv` (extensible)
- Monetary amounts MUST be stored as integers (minor currency units, e.g., cents) to
  avoid floating-point rounding errors.
- All entities MUST be modelled in the Domain layer as pure Dart classes, with separate
  Data-layer model classes handling serialization/deserialization.

## Requirements Standards

All feature specifications produced for this project MUST include:

- **Entities & fields**: name, type, nullable flag, validation rules, default values.
- **User flows**: step-by-step description of what the user does and what the system responds.
- **Validation rules**: required fields, value ranges, format constraints, and error messages.
- **Edge cases**: empty states, concurrent edit (not applicable — single user), invalid input,
  large data sets (> 1 000 records).
- **Performance considerations**: list screens MUST paginate or use lazy loading beyond 500 rows;
  report queries MUST complete in < 500 ms on device.
- **Extensibility notes**: flag any design decisions that would need to change for multi-currency
  or multi-user support.

## Tech Stack Constraints

- **Language / Framework**: Dart ≥ 3.0, Flutter ≥ 3.x. No platform-specific code without
  explicit justification.
- **State Management**: A single approach MUST be chosen (e.g., Riverpod, Bloc) and applied
  uniformly across all features. Mixing patterns is prohibited.
- **Local Storage**: `sqflite` for all structured/relational data. `shared_preferences` for
  scalar settings only. Raw file I/O is not permitted for structured data.
- **CSV Export**: MUST be implemented with a lightweight utility (e.g., `csv` package or
  manual string building). Heavy server-side generation is out of scope.
- **Theming**: Material 3. A single `ThemeData` at the app root; hardcoded colours in widget
  trees are prohibited.
- **Dependencies**: Every third-party package MUST have its purpose documented in `pubspec.yaml`
  comments. Packages with no pub.dev activity in > 12 months MUST be avoided.

## UX & Quality Standards

- Interactions MUST be minimal and intuitive — optimize for fast data entry (the add-transaction
  flow MUST be reachable in ≤ 2 taps from any screen).
- All screens MUST be responsive across phone form factors (320 dp – 428 dp width).
- Every data-fetching widget MUST handle: loading state, empty state, and error state.
- Currency amounts MUST display with locale-appropriate format and symbol; the currency symbol
  MUST be configurable in settings.
- Report/chart screens MUST include accessibility semantics labels for screen readers.
- Filtering MUST support: date range, category, transaction type. All filters MUST be
  combinable.
- App MUST reach a usable state in < 2 s on a mid-range device (cold start).
- Dashboard MUST surface: current-month total income, total expenses, and net balance —
  prominently and at a glance.

## MVP Constraints

- **Single-user system**: No authentication, no multi-user data isolation required.
- **No backend**: All data lives on-device. No REST API, no cloud database.
- **CSV export**: Lightweight, client-side only. No server-generated reports.
- **Infrastructure**: Suitable for direct `flutter build` distribution; no CI/CD pipeline
  required for MVP, though tests MUST still pass locally.
- **Feasibility bar**: Every specified feature MUST be implementable by a small team (1–3
  engineers) within a reasonable sprint without external service dependencies.

## Governance

- This constitution supersedes all other informal practices, README notes, or verbal agreements.
- **Amendments**: Any change requires (1) documenting the motivation, (2) bumping the version,
  and (3) updating all affected templates and noting them in the Sync Impact Report.
- **Version policy**:
  - MAJOR — principle removal, redefinition, or backward-incompatible governance change.
  - MINOR — new principle, section added, or materially expanded guidance.
  - PATCH — wording clarification, typo fix, non-semantic refinement.
- **Compliance review**: Every feature spec and pull request MUST include a checklist item
  confirming no violations of the five Core Principles.
- **Spec authoring standard**: All feature specifications MUST satisfy the Requirements
  Standards section — incomplete specs are not accepted for implementation.
- **Runtime guidance**: Refer to `.specify/templates/agent-file-template.md` for up-to-date
  technology and command reference during active development.

**Version**: 1.1.0 | **Ratified**: 2026-04-03 | **Last Amended**: 2026-04-03
