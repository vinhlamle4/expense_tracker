# Implementation Plan: Unit Testing - 80% Coverage Logic App

**Branch**: `004-unit-testing-80pct` | **Date**: 2026-04-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-unit-testing-80pct/spec.md`

## Summary

Comprehensive unit testing suite for Expense Tracker app core business logic (ViewModels, Repositories, Services) targeting 80% code coverage. Tests will follow BDD principles with full coverage of happy paths, edge cases, invalid inputs, boundary values, and failure scenarios. Uses mocktail for dependency mocking and flutter_test framework. Scope: local development only (no CI/CD).

## Technical Context

**Language/Version**: Dart 3.11.1 (Flutter SDK ^3.11.1)

**Primary Dependencies**:
- **State Management**: hooks_riverpod 2.6.1, flutter_hooks 0.21.1
- **Database**: Isar 3.1.0+1 (local NoSQL)
- **CSV Export**: csv 6.0.0
- **Permissions**: permission_handler 11.3.1
- **Testing**: flutter_test (built-in), mocktail (^1.0.0 - for mocking)

**Storage**: Isar (embedded NoSQL) for transactions, categories, settings  
**Testing**: flutter_test + mocktail  
**Target Platform**: Android & iOS (mobile)  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: Tests complete in <30 seconds (flexible), 80%+ coverage per component  
**Constraints**: No real database/file I/O (all mocked), local dev only, <30s execution (target)  
**Scale/Scope**: 7 business logic components, ~11 test files, 80+ test cases

## Constitution Check

✅ **GATE: PASSED**

**Principles Verified**:
- ✅ **Principle I** (Functionality First): Tests focus on core transaction, category, dashboard logic
- ✅ **Principle II** (User Value): Each test validates user-facing requirements
- ✅ **Principle III** (Explicit Data Flows): Tests verify data movement through architecture
- ✅ **Principle IV** (No Surprise Behavior): All edge cases and failures explicitly tested
- ✅ **Principle V** (Defensive Code): Tests verify error handling, validation, boundaries
- ✅ **Principle VI** (Security & Permissions): PermissionService tests verify rationale, denials

## Project Structure

### Documentation (this feature)

```text
specs/004-unit-testing-80pct/
├── spec.md                  # Feature specification (clarified)
├── plan.md                  # This file (implementation plan)
├── research.md              # Phase 0 output (research findings)
├── data-model.md            # Phase 1 output (test model)
├── quickstart.md            # Phase 1 output (implementation guide)
├── contracts/               # Phase 1 output (test contracts/patterns)
├── checklists/
│   └── requirements.md      # Quality checklist
└── tasks.md                 # Phase 2 output (detailed task breakdown)
```

### Source Code (Repository Structure)

```text
lib/                         # Source code (existing)
├── core/
│   ├── database/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   └── repositories/
├── features/
│   ├── dashboard/
│   ├── transaction/
│   └── settings/
└── shared/
    ├── providers/
    └── widgets/

test/unit/                   # Unit tests (NEW)
├── models/
│   ├── transaction_model_test.dart
│   ├── category_model_test.dart
│   └── settings_model_test.dart
├── data/repositories/
│   ├── transaction_repository_test.dart
│   ├── category_repository_test.dart
│   └── settings_repository_test.dart
├── features/
│   ├── transaction/viewmodels/
│   │   └── transaction_view_model_test.dart
│   ├── dashboard/viewmodels/
│   │   └── dashboard_view_model_test.dart
│   └── settings/viewmodels/
│       └── theme_view_model_test.dart
├── core/utils/
│   ├── csv_export_service_test.dart
│   └── permission_service_test.dart
└── shared/providers/
    └── (if needed)

test/fixtures/               # Test helpers (NEW)
├── mocks.dart               # Mock definitions
└── fixtures.dart            # Test data factory
```

**Structure Decision**: Single Flutter project with unit tests in `test/unit/` mirroring `lib/` structure. Follows Flutter conventions.

## Test Coverage Requirements

### 1. Happy Path Coverage
**Definition**: Normal, expected usage with valid inputs

Covers: All user story primary flows with valid data, correct calculations, successful operations

### 2. Edge Case Coverage
**Definition**: Boundary conditions, unusual but valid scenarios

Covers: 1000+ transactions, empty lists, month/year boundaries, week spans, single-category scenarios

### 3. Invalid Input Coverage
**Definition**: Data violating constraints or expectations

Covers: Zero/negative amounts, invalid theme modes, non-existent IDs, null values

### 4. Boundary Value Coverage
**Definition**: Values at edges of valid ranges

Covers: Min/max amounts, date boundaries, category count limits, filename increments (100+)

### 5. Failure Scenario Coverage
**Definition**: Error conditions and recovery mechanisms

Covers: Database errors, file write failures, permission denied, missing categories, calculation errors

---

## Phase 0: Research & Analysis

### Research Tasks (Estimated: 8 hours)

**R1: Mocktail Mocking Patterns for Isar**
- Mock Isar database, collections, transactions
- Mocking writeTxn(), put(), delete(), streams
- Reusable mock builders for tests

**R2: Flutter Permission Handler Mocking**
- Mocking Permission states (granted, denied, permanent)
- Dialog interaction with mocked BuildContext
- Platform-specific permission flows

**R3: File I/O Testing Strategies**
- Mocking File and Directory for CSV tests
- Temporary directory usage patterns
- Error handling for permission denied scenarios

**R4: Riverpod Testing Patterns**
- Testing AsyncNotifier ViewModels
- State transition verification
- Provider dependency injection in tests

**R5: Stream Testing in Dart**
- Testing watchAll() streams from repositories
- Stream emission verification
- Cancellation and cleanup patterns

**R6: DateTime Boundary Testing**
- Period filtering across month/year boundaries
- Week calculation validation
- Timezone considerations

**Output**: `research.md` with patterns, examples, and best practices

---

## Phase 1: Design & Contracts

### Phase 1A: Test Data Models (Estimated: 4 hours)

**D1: Test Data Factories**
- TransactionModel builder with various scenarios
- CategoryModel factory with test data
- SettingsModel for theme testing
- Test data for boundary/edge cases

**D2: Mock Definitions**
- MockIsar, MockIsarCollection
- MockRepository classes
- MockBuildContext, MockPermission, MockFile, MockDirectory
- Mock setup helpers

**D3: Test Organization Matrix**
- Map user stories to test files
- Coverage areas per component
- Happy path + edge case distribution

**Output**: `data-model.md` with test model structure

### Phase 1B: Test Patterns & Contracts (Estimated: 3 hours)

**C1: Happy Path Pattern** - Normal operation with valid data
**C2: Edge Case Pattern** - Boundary conditions with assertions
**C3: Invalid Input Pattern** - Error verification
**C4: Async Pattern** - Mocked async operations
**C5: Stream Pattern** - Testing reactive updates

**Output**: `contracts/test-patterns.md` with code examples

### Phase 1C: Quickstart Guide (Estimated: 2 hours)

**Contents**:
- Setup instructions (pubspec, directories)
- Running tests commands
- Coverage report generation
- Debugging tips

**Output**: `quickstart.md`

---

## Phase 2: Implementation - Test Files

### Phase 2A: Foundation (Estimated: 5 hours)

**Task 2A.1**: `test/fixtures/fixtures.dart`
- TransactionModel builders (income, expense, various amounts)
- CategoryModel builders (default, custom)
- SettingsModel builders
- Edge case data builders

**Task 2A.2**: `test/fixtures/mocks.dart`
- All mock classes using mocktail
- Mock setup helpers
- Reusable mock builders

**Task 2A.3**: Model Tests
- `transaction_model_test.dart` (creation, fields)
- `category_model_test.dart` (factories, hash, colors)
- `settings_model_test.dart` (theme modes, singleton)

**Effort**: 5 hours | **Difficulty**: Low

### Phase 2B: Repository Tests (Estimated: 10 hours)

**Task 2B.1**: `transaction_repository_test.dart` (3 hours)
- Happy: add, update, delete, getAll, watchAll
- Edge: 1000+ transactions
- Invalid: null IDs
- Boundary: date ranges
- Failure: DB errors

**Task 2B.2**: `category_repository_test.dart` (3 hours)
- Happy: CRUD, seedDefaults
- Edge: idempotent seeding
- Invalid: duplicate IDs
- Boundary: category count
- Failure: seed errors

**Task 2B.3**: `settings_repository_test.dart` (2 hours)
- Happy: init, theme persistence
- Invalid: invalid modes
- Boundary: singleton ID=0
- Failure: persistence errors

**Effort**: 10 hours | **Difficulty**: Medium

### Phase 2C: ViewModel Tests (Estimated: 14 hours)

**Task 2C.1**: `transaction_view_model_test.dart` (5 hours)
- Happy: _compute() with all filters
- Edge: 1000+ transactions, empty
- Invalid: filter combinations
- Boundary: date edges
- Failure: missing categories

**Task 2C.2**: `dashboard_view_model_test.dart` (5 hours)
- Happy: Day/Week/Month periods
- Edge: month/year boundaries
- Invalid: missing categories
- Boundary: period transitions
- Failure: calculation errors

**Task 2C.3**: `theme_view_model_test.dart` (2 hours)
- Happy: setThemeMode (light, dark, system)
- Invalid: invalid modes
- Failure: persistence errors

**Effort**: 14 hours | **Difficulty**: High

### Phase 2D: Service Tests (Estimated: 12 hours)

**Task 2D.1**: `csv_export_service_test.dart` (6 hours)
- Happy: CSV generation, path resolution
- Edge: 1000+ transactions, filename conflicts
- Invalid: empty transactions
- Boundary: 100+ increments
- Failure: write errors, permission denied

**Task 2D.2**: `permission_service_test.dart` (6 hours)
- Happy: iOS bypass, Android flow
- Edge: context unmounted
- Invalid: invalid states
- Boundary: state transitions
- Failure: permanent denial, rejection

**Effort**: 12 hours | **Difficulty**: High

### Phase 2E: Integration & Polish (Estimated: 5 hours)

**Task 2E.1**: Coverage Report
- Run `flutter test --coverage`
- Verify 80%+ per component
- Document gaps

**Task 2E.2**: Documentation
- Update README
- Create coverage summary
- Document test patterns

**Task 2E.3**: Quality Checks
- All tests pass
- No interdependencies
- Proper mock isolation
- Cleanup in tearDown()

**Effort**: 5 hours | **Difficulty**: Low

---

## Implementation Timeline

```
Phase 0: Research                 (~8 hours)
├─ R1-R6: Research tasks
└─ Output: research.md

Phase 1: Design & Contracts       (~9 hours)
├─ 1A: Test data models          (~4 hours)
├─ 1B: Test patterns             (~3 hours)
├─ 1C: Quickstart guide          (~2 hours)
└─ Output: data-model.md, contracts/*, quickstart.md

Phase 2: Implementation           (~46 hours)
├─ 2A: Foundation                (~5 hours)
├─ 2B: Repositories              (~10 hours)
├─ 2C: ViewModels                (~14 hours)
├─ 2D: Services                  (~12 hours)
├─ 2E: Polish                    (~5 hours)
└─ Output: 11 test files, coverage report

TOTAL ESTIMATED EFFORT: ~63 hours
```

**Can be parallelized**:
- R1-R6 (research) - sequential but fast
- 2A foundations - must be first
- 2B-2D tests - can run in parallel
- 2E polish - after all tests

---

## Success Metrics

| Metric | Target | Verification |
|--------|--------|--------------|
| **Overall Coverage** | 80% per component | `flutter test --coverage` LCOV report |
| **Test Pass Rate** | 100% | All tests pass consistently |
| **Execution Time** | <30s local | Measure actual time |
| **Happy Paths** | All covered | Tests for primary flows |
| **Edge Cases** | 9 specified | All edge cases have tests |
| **Invalid Inputs** | 100% coverage | Tests verify rejection/error |
| **Boundaries** | All tested | Min, max, transitions |
| **Failures** | All scenarios | Error handling verified |
| **Documentation** | Complete | README, patterns, quickstart |

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Mock complexity | Medium | Medium | Start simple, add gradually |
| Stream testing issues | Medium | Medium | Test patterns upfront |
| DateTime edge cases | High | High | Comprehensive boundary tests |
| Flaky tests | Low | High | Proper cleanup, no timing deps |
| Coverage gaps | Low | Medium | Track coverage as written |
| Performance timeout | Low | Medium | Profile and optimize if needed |

---

## Prerequisites & Setup

### Required in pubspec.yaml
- ✅ flutter_test (built-in)
- ✅ mocktail (^1.0.0) - added in clarifications

### Directory Setup
```bash
mkdir -p test/unit/models
mkdir -p test/unit/data/repositories
mkdir -p test/unit/features/transaction/viewmodels
mkdir -p test/unit/features/dashboard/viewmodels
mkdir -p test/unit/features/settings/viewmodels
mkdir -p test/unit/core/utils
mkdir -p test/fixtures
```

### Run Tests
```bash
flutter test                           # All tests
flutter test --watch                   # Watch mode
flutter test --coverage                # Generate LCOV
```

---

## Deliverables Checklist

### Phase 0: Research
- [ ] research.md (mocktail patterns, permission handling, stream testing)
- [ ] Example code for each research topic

### Phase 1: Design
- [ ] data-model.md (test structure, factories, mocks)
- [ ] contracts/test-patterns.md (BDD patterns)
- [ ] quickstart.md (setup & usage)

### Phase 2: Implementation
- [ ] test/fixtures/fixtures.dart
- [ ] test/fixtures/mocks.dart
- [ ] test/unit/models/ (3 files)
- [ ] test/unit/data/repositories/ (3 files)
- [ ] test/unit/features/*/viewmodels/ (3 files)
- [ ] test/unit/core/utils/ (2 files)
- [ ] Coverage report (LCOV format)
- [ ] Updated README with test instructions

**Total**: 11 test files + 4 design documents

---

## Ready to Proceed

✅ Specification complete  
✅ Implementation plan defined  
✅ Tech stack identified  
✅ Coverage requirements specified  

**Next Action**: Begin Phase 0 Research


