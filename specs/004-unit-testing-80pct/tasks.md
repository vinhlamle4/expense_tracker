# Task Breakdown: Unit Testing - 80% Coverage Logic App

**Feature**: `004-unit-testing-80pct`  
**Branch**: `004-unit-testing-80pct`  
**Created**: 2026-04-09  
**Plan Reference**: [plan.md](plan.md)  
**Spec Reference**: [spec.md](spec.md)

---

## Executive Summary

This document breaks down the implementation plan into **66 actionable tasks** organized across **5 phases**:

- **Phase 0**: Research & Learning (8 tasks)
- **Phase 1**: Design & Contracts (10 tasks)
- **Phase 2A**: Foundation (4 tasks)
- **Phase 2B**: Repository Tests (10 tasks)
- **Phase 2C**: ViewModel Tests (11 tasks)
- **Phase 2D**: Service Tests (15 tasks)
- **Phase 2E**: Polish & Verification (7 tasks)

**Total Effort**: ~63 hours  
**Parallelizable**: Phases 2B-2D (repositories, ViewModels, services can run in parallel)

---

## Phase 0: Research & Learning (8 hours)

### Objective
Understand mocktail patterns, permission handling, stream testing, datetime logic, and Riverpod best practices.

**Output**: `research.md` with code examples and best practices

---

- [ ] R001 Research Mocktail patterns for Isar database mocking (1.5h)
  - Goal: Understand how to mock Isar collections, writeTxn, put, delete, watch
  - Deliverable: Code examples for MockIsar, MockIsarCollection setup
  - Reference: lib/core/database/isar_database.dart, lib/data/repositories/*.dart

- [ ] R002 Research permission handler mocking strategies (1.5h)
  - Goal: Learn how to mock Permission states (granted, denied, permanentlyDenied)
  - Deliverable: MockPermission usage patterns with different states
  - Reference: lib/core/utils/permission_service.dart

- [ ] R003 Research File I/O mocking and testing (1h)
  - Goal: Mock File, Directory, path_provider for CSV export tests
  - Deliverable: Patterns for error scenarios (permission denied, storage unavailable)
  - Reference: lib/core/utils/csv_export_service.dart

- [ ] R004 Research Riverpod AsyncNotifier testing (1.5h)
  - Goal: Learn how to test AsyncNotifier ViewModels with mocked dependencies
  - Deliverable: Test setup patterns for state providers
  - Reference: lib/features/transaction/viewmodels/transaction_view_model.dart

- [ ] R005 Research Dart Stream testing patterns (1h)
  - Goal: Understand how to test reactive streams, verify emissions
  - Deliverable: Examples of testing watchAll() streams
  - Reference: lib/data/repositories/transaction_repository.dart

- [ ] R006 Research DateTime boundary testing (1h)
  - Goal: Test period filtering across month/year boundaries, week calculations
  - Deliverable: Date range and period testing patterns
  - Reference: lib/features/dashboard/viewmodels/dashboard_view_model.dart

- [ ] R007 Compile findings and create research.md (0.5h)
  - Goal: Document all research findings with code examples
  - Deliverable: specs/004-unit-testing-80pct/research.md
  - Contains: Best practices, gotchas, proven patterns

- [ ] R008 Review and validate all research patterns (0.5h)
  - Goal: Ensure all patterns work and are production-ready
  - Deliverable: Validated research.md ready for Phase 1

---

## Phase 1: Design & Contracts (9 hours)

### Objective
Design test data models, mock definitions, test patterns, and create implementation guide.

**Output**: `data-model.md`, `contracts/test-patterns.md`, `quickstart.md`

---

### 1A: Test Data Models (4 hours)

- [ ] D001 Design TransactionModel test data builders (1h)
  - Goal: Create factory methods for various transaction scenarios
  - Deliverable: fixtures/fixtures.dart with transaction builders
  - Coverage: happy path, edge cases (1000+ items), boundary (min/max amounts)
  - Reference: lib/data/models/transaction_model.dart

- [ ] D002 Design CategoryModel test data builders (0.75h)
  - Goal: Factory methods for default and custom categories
  - Deliverable: fixtures/fixtures.dart with category builders
  - Coverage: Income/Expense types, custom categories, hash validation
  - Reference: lib/data/models/category_model.dart

- [ ] D003 Design SettingsModel test data builders (0.5h)
  - Goal: Create test settings for all theme modes
  - Deliverable: fixtures/fixtures.dart with settings builders
  - Coverage: light, dark, system modes
  - Reference: lib/data/models/settings_model.dart

- [ ] D004 Create comprehensive test fixture file (1.75h)
  - Goal: Consolidate all test data factories into single file
  - Deliverable: test/fixtures/fixtures.dart (complete)
  - Contains: All factory methods, edge case data, boundary values
  - Functions: createTransaction(), createCategory(), createSettings(), etc.

### 1B: Mock Definitions (3 hours)

- [ ] D005 Design MockIsar database structure (1h)
  - Goal: Define mock Isar with all required collections
  - Deliverable: test/fixtures/mocks.dart with MockIsar class
  - Mocks: transactionModels, categoryModels, settingsModels collections
  - Reference: lib/core/database/isar_database.dart

- [ ] D006 Design repository mock classes (1h)
  - Goal: Create mock repositories for testing ViewModels
  - Deliverable: test/fixtures/mocks.dart with mock repositories
  - Mocks: MockTransactionRepository, MockCategoryRepository, MockSettingsRepository
  - Reference: lib/data/repositories/*.dart

- [ ] D007 Design service and utility mock classes (1h)
  - Goal: Create mocks for File, Directory, Permission, Platform, BuildContext
  - Deliverable: test/fixtures/mocks.dart with all service mocks
  - Complete: Finalize test/fixtures/mocks.dart file

### 1C: Test Organization & Patterns (2 hours)

- [ ] D008 Create test patterns documentation (1h)
  - Goal: Document BDD patterns for all test types
  - Deliverable: specs/004-unit-testing-80pct/contracts/test-patterns.md
  - Patterns: Happy path, Edge case, Invalid input, Boundary, Failure
  - Examples: Code for each pattern type

- [ ] D009 Create quickstart guide (1h)
  - Goal: Setup instructions, running tests, coverage verification
  - Deliverable: specs/004-unit-testing-80pct/quickstart.md
  - Contains: Directory creation, pubspec updates, running commands, coverage steps

---

## Phase 2A: Foundation Setup (5 hours)

### Objective
Create test infrastructure: fixtures, mocks, and basic model tests.

**Output**: Fixture files, mock definitions, and initial test structure

---

- [X] T001 Create test/fixtures/ directory structure
- [X] T002 Implement test/fixtures/fixtures.dart (complete)
- [X] T003 Implement test/fixtures/mocks.dart (complete)
- [X] T004 [P] Implement basic model tests (3 files)

---

## Phase 2B: Repository Tests (10 hours)

### Objective
Comprehensive tests for all database repository operations.

**Output**: 3 complete repository test files with 26 tests total

---

- [X] T005 [P] Implement test/unit/data/repositories/transaction_repository_test.dart (3h)
- [X] T006 [P] Implement test/unit/data/repositories/category_repository_test.dart (3h)
- [X] T007 [P] Implement test/unit/data/repositories/settings_repository_test.dart (2h)
- [X] T008 [P] Verify repository test coverage (2h)
  - Goal: Run repository tests, verify 80%+ coverage
  - Command: flutter test test/unit/data/repositories/ --coverage
  - Verify: LCOV report shows 80%+ for each repository
  - Coverage Target: TransactionRepository ≥80%, CategoryRepository ≥80%, SettingsRepository ≥80%
  - Deliverable: Coverage report snapshot

---

## Phase 2C: ViewModel Tests (14 hours)

### Objective
Comprehensive tests for business logic ViewModels (filtering, calculations, state management).

**Output**: 3 complete ViewModel test files with 30 tests total

---

- [X] T009 [P] Implement test/unit/features/transaction/viewmodels/transaction_view_model_test.dart (5h)
- [X] T010 [P] Implement test/unit/features/dashboard/viewmodels/dashboard_view_model_test.dart (5h)
- [X] T011 [P] Implement test/unit/features/settings/viewmodels/theme_view_model_test.dart (2h)
- [X] T012 [P] Verify ViewModel test coverage (2h)
  - Goal: Run ViewModel tests, verify 80%+ coverage
  - Command: flutter test test/unit/features/*/viewmodels/ --coverage
  - Verify: LCOV report shows 80%+ for each ViewModel
  - Coverage Target: TransactionViewModel ≥80%, DashboardViewModel ≥80%, ThemeViewModel ≥80%
  - Deliverable: Coverage report snapshot

---

## Phase 2D: Service Tests (12 hours)

### Objective
Comprehensive tests for CSV export and permission services.

**Output**: 2 complete service test files with 26 tests total

---

- [X] T013 [P] Implement test/unit/core/utils/csv_export_service_test.dart (6h)
- [X] T014 [P] Implement test/unit/core/utils/permission_service_test.dart (6h)
- [X] T015 [P] Verify service test coverage (2h)
  - Goal: Run service tests, verify 80%+ coverage
  - Command: flutter test test/unit/core/utils/ --coverage
  - Verify: LCOV report shows 80%+ for each service
  - Coverage Target: CsvExportService ≥80%, PermissionService ≥80%
  - Deliverable: Coverage report snapshot

---

## Phase 2E: Polish & Verification (7 hours)

### Objective
Generate coverage reports, verify targets, update documentation, final quality checks.

**Output**: Coverage report, updated README, final verification

---

- [X] T016 Run complete test suite and generate coverage report (2h)
- [X] T017 Verify 80% coverage target per component (2h)
- [X] T018 Document test coverage results (1h)
- [X] T019 Update README with test instructions (1h)
- [X] T020 Create test patterns reference guide (1h)

---

## Dependencies & Execution Notes

### Critical Dependencies (Must Complete in Order)

1. **Phase 0 → Phase 1**: Research findings inform design
2. **Phase 1A → Phase 1B**: Fixtures must be defined before mocks
3. **Phase 1 → Phase 2A**: Design complete before implementation
4. **Phase 2A → Phase 2B-D**: Foundation (fixtures, mocks) must exist
5. **Phase 2B-D → Phase 2E**: All tests must pass before coverage verification

### Parallelizable Work

**Can run in parallel** (after Phase 2A):
- Phase 2B: Repository tests
- Phase 2C: ViewModel tests
- Phase 2D: Service tests

**Cannot run in parallel**:
- Phase 0 (sequential, builds on itself)
- Phase 1 (depends on Phase 0)
- Phase 2A (foundation for all)
- Phase 2E (depends on all tests)

---

## Success Criteria per Task Type

### Research Tasks (Phase 0)
- ✅ Code examples provided for each pattern
- ✅ Best practices documented
- ✅ Gotchas and edge cases identified

### Design Tasks (Phase 1)
- ✅ Complete fixture file with all factories
- ✅ Complete mock file with all definitions
- ✅ Test patterns documented with examples
- ✅ Quickstart guide actionable

### Test Implementation Tasks (Phase 2B-D)
- ✅ All tests pass (100% pass rate)
- ✅ Each test isolated (no interdependencies)
- ✅ Proper setup/teardown in all tests
- ✅ Mocks properly verified (when applicable)
- ✅ Coverage ≥80% for component

### Verification Tasks (Phase 2E)
- ✅ All 7 components ≥80% coverage
- ✅ Overall coverage ≥80%
- ✅ Documentation complete
- ✅ No flaky tests

---

## Effort Summary

| Phase | Tasks | Hours | Status |
|-------|-------|-------|--------|
| **Phase 0** | 8 | 8h | Not Started |
| **Phase 1** | 10 | 9h | Not Started |
| **Phase 2A** | 4 | 5h | Not Started |
| **Phase 2B** | 4 | 10h | Not Started |
| **Phase 2C** | 4 | 14h | Not Started |
| **Phase 2D** | 3 | 12h | Not Started |
| **Phase 2E** | 5 | 5h | Not Started |
| **TOTAL** | **38 Task Groups** | **63h** | ✅ Ready |

---

## Getting Started

### Prerequisites
- [ ] Read plan.md thoroughly
- [ ] Review spec.md requirements
- [ ] Verify pubspec.yaml has mocktail dependency
- [ ] Create test directory structure

### First Steps
1. Begin Phase 0: Start with R001 (Mocktail patterns)
2. Complete all R00x tasks in order
3. Create research.md with findings
4. Proceed to Phase 1 after Phase 0 complete

### Running Tests During Development
```bash
# Run all tests
flutter test

# Run specific phase tests
flutter test test/unit/data/repositories/

# Watch mode (re-run on changes)
flutter test --watch

# Generate coverage
flutter test --coverage

# Verbose output
flutter test -v
```

---

## Task Status Tracking

- [ ] All Phase 0 tasks (research)
- [ ] All Phase 1 tasks (design)
- [ ] All Phase 2A tasks (foundation)
- [ ] All Phase 2B tasks (repositories)
- [ ] All Phase 2C tasks (ViewModels)
- [ ] All Phase 2D tasks (services)
- [ ] All Phase 2E tasks (verification)

**Total Progress**: 0/38 Task Groups | 0/66 Individual Tasks

---

**Next Action**: Begin Phase 0 with R001 (Mocktail patterns research)


