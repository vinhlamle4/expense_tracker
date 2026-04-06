<!--
  SYNC IMPACT REPORT
  ==================
  Version change: (unversioned template) → 1.0.0
  Bump type: MINOR — initial population; all principles and sections are new.

  Principles added (all new):
    - I.  MVVM Architecture (NON-NEGOTIABLE)
    - II. Material Design 3 Compliance (NON-NEGOTIABLE)
    - III. Local-First Storage
    - IV. State Management via hooks_riverpod
    - V.  Coding Standards

  Sections added:
    - UI/UX & Theme Rules
    - Project Tooling
    - Governance

  Templates requiring updates:
    ✅ .specify/templates/plan-template.md      — aligned; "Constitution Check" gate
                                                  now references Principles I–V.
    ✅ .specify/templates/spec-template.md      — aligned; FR/SC/user-story structure
                                                  is compatible with Flutter mobile scope.
    ✅ .specify/templates/tasks-template.md     — aligned; phase/story model is
                                                  framework-agnostic; mobile path
                                                  conventions (lib/, test/) apply.
    ✅ .specify/templates/agent-file-template.md — aligned; populated per feature plan;
                                                  no outdated agent-specific references.
    ✅ .specify/templates/checklist-template.md  — aligned; generic structure,
                                                  no outdated agent-specific names.

  Deferred TODOs: None.
-->

# Expense Tracker Constitution

## Core Principles

### I. MVVM Architecture (NON-NEGOTIABLE)

All features MUST follow the Model-View-ViewModel (MVVM) architecture pattern:

- **Model**: Data entities and repository classes that handle local persistence only.
- **ViewModel**: ALL business logic, data calculations, formatting, and state
  transformations MUST reside in the ViewModel layer. No exceptions.
- **View**: Flutter Widgets are responsible solely for rendering UI and forwarding
  user events to the ViewModel. A Widget MUST NOT compute, filter, or aggregate
  data — if a `map`, `reduce`, `sort`, or conditional business rule appears in a
  Widget build method, it is a violation.
- The boundary is enforced at import level: Widget files MUST NOT import repository
  or database classes directly; all data access flows through Providers/ViewModels.

**Rationale**: Clear separation makes ViewModels independently unit-testable without
the Flutter framework, keeps widget tests pure UI assertions, and prevents business
logic from scattering across the widget tree as the app grows.

### II. Material Design 3 Compliance (NON-NEGOTIABLE)

All UI MUST conform strictly to Material Design 3 (M3) guidelines:

- The app MUST be initialized with `useMaterial3: true` in `ThemeData`.
- Dynamic Color MUST be supported: the device's system-generated color scheme is
  applied when available (e.g., via the `dynamic_color` package).
- Adaptive Layout MUST be applied so that layouts adjust gracefully to varying
  screen sizes and form factors.
- Hard-coding color values (hex literals, RGB constants, named `Colors.*` values
  used outside the central theme definition) is STRICTLY PROHIBITED.
  All colors in feature code MUST be referenced via `Theme.of(context).colorScheme`
  semantic tokens (e.g., `colorScheme.primary`, `colorScheme.surface`).

**Rationale**: Strict M3 adherence ensures visual consistency, platform-native
feel, accessibility compliance, and correct behavior under Dynamic Color and
Dark Mode without per-widget color patches.

### III. Local-First Storage

The application operates in an **offline-first, local-only** data model:

- Data persistence MUST use either **Isar** or **Drift** (the choice is fixed per
  feature plan and MUST remain consistent within that feature).
- Remote/REST API calls are STRICTLY PROHIBITED for any core data operation.
  No `http`, `dio`, or equivalent network client may be introduced for data access.
- The app MUST be fully functional without any network connectivity.
- Theme preference (light/dark/system) MUST be persisted to the local database
  and restored on app launch before the first frame is rendered (no flicker).

**Rationale**: Full offline capability protects user privacy, eliminates dependency
on external infrastructure, and keeps the data layer simple and auditable.

### IV. State Management via hooks_riverpod

All application state MUST be managed using `hooks_riverpod` combined with
`flutter_hooks`:

- Providers (`AsyncNotifierProvider`, `NotifierProvider`, `StateProvider`, etc.)
  are the single source of truth for all shared or persistent state.
- `HookConsumerWidget` is the PREFERRED base class for all feature widgets.
  `ConsumerWidget` may be used only for stateless consumer widgets with no local
  ephemeral state.
- `StatefulWidget` MUST NOT be used unless an unavoidable third-party API
  explicitly requires a `State` object (must be documented as a Complexity
  Tracking entry in the plan).
- Local ephemeral UI state (animation controllers, text controllers, focus nodes,
  scroll controllers) MUST be managed via `flutter_hooks` primitives (`useState`,
  `useAnimationController`, `useTextEditingController`, etc.).

**Rationale**: Eliminates `StatefulWidget` lifecycle complexity, makes reactive
dependencies explicit, and simplifies disposal via hooks — reducing boilerplate
and state-related bugs.

### V. Coding Standards

Uniform naming, structure, and clean-code rules apply across the entire codebase:

- **File naming**: `snake_case` (e.g., `expense_list_view.dart`,
  `transaction_repository.dart`).
- **Class naming**: `PascalCase` (e.g., `ExpenseListViewModel`, `IsarRepository`).
- **Variable / method naming**: `camelCase` (e.g., `totalExpense`,
  `fetchExpenses()`).
- **One widget per file**: Each file exposes exactly one primary public Widget;
  the file name MUST match the widget class name in snake_case.
- **Import discipline**: Use relative imports within the same feature module;
  use absolute `package:expense_tracker/…` imports for cross-module references.
- **Dependency pinning**: All direct dependencies in `pubspec.yaml` MUST use
  pinned or tightly bounded version constraints; floating `any` constraints are
  prohibited.
- `analysis_options.yaml` MUST enable `flutter_lints` (or a stricter superset).
  Lint rule suppressions require an inline comment justifying the exception.

**Rationale**: Consistent conventions reduce cognitive load during reviews,
enforce the MVVM boundary at the file-import level, and ensure the dependency
graph is reproducible and auditable.

## UI/UX & Theme Rules

Additional interface rules that complement Principle II:

- **Theme Modes**: The app MUST support **Light**, **Dark**, and **System** modes.
  The selected mode MUST be persisted to the local DB (Principle III) and applied
  on next launch without a visible flash or rebuild.
- **No Magic Numbers**: Spacing, border-radius, and elevation values MUST reference
  `Theme.of(context)` tokens or named constants defined in a central theme file
  (`lib/core/theme/`). Raw pixel literals are permitted only inside the central
  theme definition file itself.
- **Component Reuse**: Shared UI elements (cards, dialogs, input fields, bottom
  sheets) MUST be extracted into a `lib/shared/widgets/` directory and referenced
  across feature modules. Duplicating widget implementations is a violation.
- **Accessibility**: All interactive elements MUST carry `Semantics` labels or
  use widgets that inherit them. Minimum touch-target size follows M3 guidelines
  (48 × 48 logical pixels).

## Project Tooling

Tools and process conventions governing the development environment:

- **Flutter Channel**: Latest stable channel. The `flutter` SDK constraint in
  `pubspec.yaml` MUST reflect the minimum supported stable version.
- **MCP Server (Context7)**: Used for project context management. All agents and
  developers MUST consult Context7 before implementing features that touch shared
  data models, providers, or the theme layer, to avoid conflicting changes.
- **Database Choice**: Isar or Drift is decided once per feature in `plan.md`.
  Switching databases mid-feature requires a plan amendment and a version bump
  to this constitution.
- **Linting**: `flutter_lints ^6.0.0` (or stricter) is mandatory. The CI pipeline
  MUST fail on any analysis warning that is not explicitly suppressed with
  justification.

## Governance

This Constitution supersedes all other development conventions, README instructions,
and ad-hoc agreements for the Expense Tracker project.

- **Amendments**: Any change to a Core Principle requires a version bump (MINOR or
  MAJOR) and an updated `LAST_AMENDED_DATE`. All amendments MUST be summarized in
  the Sync Impact Report at the top of this file.
- **Compliance Review**: Every pull request MUST include a "Constitution Check"
  section in the associated `plan.md` that explicitly verifies alignment with
  Principles I–V before Phase 0 research and again after Phase 1 design.
- **Versioning Policy**:
  - **MAJOR** — Removal or fundamental redefinition of a Core Principle.
  - **MINOR** — Addition of a new principle or material expansion of an existing
    section.
  - **PATCH** — Clarifications, wording improvements, or typo corrections.
- **Violations**: Code or design decisions that violate a NON-NEGOTIABLE principle
  (Principles I and II) MUST be reverted or remediated before merge. Temporary
  exceptions to other principles MUST be documented in the plan's Complexity
  Tracking table with a remediation deadline.
- **Runtime Guidance**: Refer to `.specify/memory/constitution.md` (this file)
  as the authoritative governance document in all agent-assisted development
  sessions via Context7.

**Version**: 1.0.0 | **Ratified**: 2026-04-06 | **Last Amended**: 2026-04-06
