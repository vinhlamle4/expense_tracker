# Feature Specification: UI — Dark Theme & Material Design 3 Polish

**Feature Branch**: `002-ui-dark-theme-md3`  
**Created**: 2026-04-03  
**Status**: Draft  
**Input**: User description: "update phần UI sử dụng dark theme và material design 3"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Switch Theme Mode (Priority: P1)

A user opens Settings and chooses between Light, Dark, and System (follows device setting) theme modes. Their preference is saved and applied immediately across the entire app without requiring a restart.

**Why this priority**: Theme switching is the most visible user-facing outcome of this feature. All other M3 polish work depends on the correct `ColorScheme` being in place first.

**Independent Test**: Open Settings → Appearance, select "Dark"; observe all screens switch to dark palette immediately. Restart the app; confirm preference is remembered. Select "System", switch device to light mode, confirm the app follows.

**Acceptance Scenarios**:

1. **Given** the app is in Light mode, **When** the user selects "Dark" in Settings → Appearance, **Then** all screens immediately switch to the dark colour palette without restarting.
2. **Given** the user has selected "Dark" mode, **When** the app is closed and reopened, **Then** it launches in Dark mode (preference persisted).
3. **Given** the user selects "System", **When** the device theme is Light, **Then** the app uses the light palette; when the device switches to Dark, the app follows automatically.
4. **Given** any theme mode is active, **When** the user navigates through all 4 main tabs, **Then** every screen reflects the correct colour scheme with no hardcoded colours visible.

---

### User Story 2 — Material Design 3 Component Consistency (Priority: P2)

A user navigates through the app and experiences consistent Material Design 3 component styles: `FilledButton` for primary actions, `Card` with `surfaceContainerLow` fill, `SnackBar` with floating behaviour, and typography from the M3 type scale.

**Why this priority**: Without consistent M3 component usage, the app looks visually inconsistent even when dark theme is applied. This story delivers the visual quality improvement independent of theme switching.

**Independent Test**: Install the app; navigate through Transactions, Reports, Settings, and Add/Edit screens; verify every primary button uses a filled style, every card uses M3 surface tones, and no raw `Colors.X` constants appear in widget builds.

**Acceptance Scenarios**:

1. **Given** any primary action button (Save, Apply, Add), **When** viewed in either light or dark mode, **Then** it renders as a `FilledButton` with `colorScheme.primary` background and passes WCAG AA colour-contrast (≥ 4.5:1).
2. **Given** the transaction list and reports screens, **When** cards or list tiles are rendered, **Then** they use `colorScheme.surfaceContainerLow` (not hardcoded fills) so they adapt correctly to both modes.
3. **Given** the bottom `NavigationBar`, **When** an item is selected, **Then** the active indicator pill uses `colorScheme.secondaryContainer` per M3 spec.
4. **Given** any SnackBar feedback (e.g., "Saved: …"), **When** displayed, **Then** it uses `SnackBarBehavior.floating` with rounded corners per M3.
5. **Given** all text elements, **When** rendered, **Then** they reference M3 type scale tokens (`titleLarge`, `bodyMedium`, etc.) rather than hardcoded `fontSize` values.

---

### User Story 3 — Accessible Colour Contrast in Dark Mode (Priority: P3)

A user with reduced vision can read all text and identify all interactive elements in dark mode because every foreground/background pair meets WCAG AA contrast ratio (≥ 4.5:1 for text, ≥ 3:1 for UI components).

**Why this priority**: Colour accessibility is a correctness requirement — but can only be verified after M3 colour tokens are applied (depends on US2).

**Independent Test**: Run the app in dark mode; use a colour-contrast tool to verify text on `surface`, `primary`, `error`, and `surfaceContainerLow` backgrounds all meet WCAG AA.

**Acceptance Scenarios**:

1. **Given** dark mode is active, **When** reviewing all body and label text, **Then** every foreground/background pair achieves a contrast ratio ≥ 4.5:1.
2. **Given** dark mode is active, **When** reviewing icon-only interactive elements (filter, save CSV, back), **Then** each meets ≥ 3:1 contrast ratio against its background.
3. **Given** income (green) and expense (red) amount colours in `TransactionTile` and `DashboardSummary`, **When** displayed in dark mode, **Then** the colours are lighter tones that meet contrast requirements on dark surfaces.

---

### Edge Cases

- **First launch**: No saved preference → default to `ThemeMode.system`.
- **Rapid theme switching**: Toggling modes quickly (3+ times in 1 second) must not cause visual glitches or state corruption.
- **Hardcoded colour remnants**: Any `Colors.white`, `Colors.grey`, `Colors.black`, or raw hex literals in widget trees must be replaced with the appropriate `colorScheme` token.
- **fl_chart PieChart in dark mode**: Chart segment colours must remain visually distinct on dark backgrounds.
- **Category colour swatches**: User-defined hex colours displayed as swatches are exempt from the token rule; swatch label text adapts to `onSurface`.

---

## Requirements *(mandatory)*

### Functional Requirements

#### Theme Preference

| ID | Requirement |
|----|-------------|
| FR-001 | Users MUST be able to select a theme mode (Light / Dark / System) from Settings → Appearance. |
| FR-002 | The selected theme mode MUST be persisted across app restarts using local on-device storage. |
| FR-003 | Theme changes MUST apply immediately to all visible screens without restarting the app. |
| FR-004 | The default theme mode on first launch MUST be "System" (follows device setting). |

#### Material Design 3 Components

| ID | Requirement |
|----|-------------|
| FR-005 | All primary action buttons (form submit, filter apply, category save) MUST use `FilledButton`. |
| FR-006 | All secondary / destructive actions (cancel, clear filters) MUST use `TextButton` or `OutlinedButton`. |
| FR-007 | All card-style containers MUST use `Card` with colours resolved from `ColorScheme`. No hardcoded fill colours. |
| FR-008 | The `NavigationBar` MUST render the active-item indicator using `colorScheme.secondaryContainer`. |
| FR-009 | SnackBars system-wide MUST use `SnackBarBehavior.floating` with rounded corners (border radius 8 dp). |
| FR-010 | All text styles MUST reference M3 type-scale tokens from `textTheme` (e.g., `titleLarge`, `bodyMedium`, `labelSmall`). No hardcoded `fontSize` in widget trees. |
| FR-011 | No raw `Colors.*` constants or hex literals (other than user-defined category colours) MUST exist in any widget `build` method. All colours sourced from `colorScheme`. |

#### Colour & Accessibility

| ID | Requirement |
|----|-------------|
| FR-012 | In dark mode, income amount text MUST achieve ≥ 4.5:1 contrast against `colorScheme.surface`. |
| FR-013 | In dark mode, expense amount text MUST achieve ≥ 4.5:1 contrast against `colorScheme.surface`. |
| FR-014 | The seed colour for `ColorScheme.fromSeed` MUST be identical for both light and dark modes to ensure a coherent tonal palette. |

---

### Key Entities

- **ThemePreference**: Persisted user setting — one of `light`, `dark`, `system`. Stored via `shared_preferences` (key: `theme_mode`). Loaded at app startup before first frame.
- **AppTheme**: Single source of truth for `ThemeData` at `lib/app/theme.dart`. Extended with component-level theme overrides: `NavigationBarThemeData`, `SnackBarThemeData`, `CardTheme`, `FilledButtonThemeData`, `TextTheme`.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

| ID | Criterion |
|----|-----------|
| SC-001 | A user can switch between Light, Dark, and System modes from Settings in under 3 taps; the visual change is instant (within one frame). |
| SC-002 | Theme preference survives app restart 100% of the time. |
| SC-003 | `flutter analyze lib/` reports zero issues after all widget-tree colour references are migrated to `colorScheme` tokens. |
| SC-004 | In dark mode, all text/background colour pairs audited with a contrast tool achieve ≥ 4.5:1 (text) and ≥ 3:1 (UI components). |
| SC-005 | Zero `Colors.white`, `Colors.grey`, `Colors.black`, or raw hex literals remain in any file under `lib/` (excluding `default_categories.dart`). |
| SC-006 | All 5 primary screens render without visual overflow or clipping in both Light and Dark modes at 320 dp width. |

---

## Assumptions

- **Existing M3 base**: `AppTheme` already sets `useMaterial3: true` and defines both `light` and `dark` `ThemeData`. This feature extends rather than replaces that foundation.
- **`shared_preferences` package**: Will be added to `pubspec.yaml` as the persistence mechanism for theme preference. No database schema change is required.
- **Seed colour**: The existing seed `Color(0xFF1976D2)` (blue) is retained. A colour change is out of scope for this spec.
- **Category colours**: User-defined hex strings stored per category are displayed as-is in swatches and are exempt from the "no hardcoded colours" rule.
- **fl_chart segment colours**: Mapped directly from category `colour` fields (user data); exempt from the token rule. A neutral fallback colour is applied in dark mode only when a category has no colour set.
- **No per-screen theme override**: All screens share the single global `ThemeData`; no `Theme(data: ...)` widget wrappers per screen.

