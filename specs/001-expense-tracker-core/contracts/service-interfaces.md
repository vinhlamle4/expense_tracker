# Service Interfaces: Expense Tracker — 001-expense-tracker-core

**Layer**: Domain (Use-Cases)  
**Generated**: 2026-04-03

Use-cases encapsulate single business operations. Each use-case takes a typed input and returns a typed output. They depend only on repository interfaces — never on Flutter or sqflite.

---

## Transaction Use-Cases

### CreateTransaction

```dart
// lib/features/transactions/domain/usecases/create_transaction.dart

/// Input validation:
///   - amount > 0
///   - type is a valid TransactionType
///   - categoryId references an existing category
///   - date is a valid YYYY-MM-DD string >= 1970-01-01
///   - note length <= 500 (if provided)
///
/// Throws [ValidationException] for invalid input.
/// Throws [CategoryNotFoundException] if categoryId doesn't exist.
class CreateTransaction {
  final TransactionRepository _repository;
  const CreateTransaction(this._repository);

  Future<Transaction> call(TransactionInput input) async {
    _validate(input);
    return _repository.createTransaction(input);
  }
}
```

### UpdateTransaction

```dart
// lib/features/transactions/domain/usecases/update_transaction.dart

/// Same validation as CreateTransaction.
/// Throws [TransactionNotFoundException] if id not found.
class UpdateTransaction {
  final TransactionRepository _repository;
  const UpdateTransaction(this._repository);

  Future<Transaction> call(int id, TransactionInput input) async {
    _validate(input);
    return _repository.updateTransaction(id, input);
  }
}
```

### DeleteTransaction

```dart
// lib/features/transactions/domain/usecases/delete_transaction.dart

/// Throws [TransactionNotFoundException] if id not found.
class DeleteTransaction {
  final TransactionRepository _repository;
  const DeleteTransaction(this._repository);

  Future<void> call(int id) => _repository.deleteTransaction(id);
}
```

### GetTransactions

```dart
// lib/features/transactions/domain/usecases/get_transactions.dart

/// Returns paginated transactions matching the given filters.
/// No additional validation — invalid filter values return empty results.
class GetTransactions {
  final TransactionRepository _repository;
  const GetTransactions(this._repository);

  Future<PaginatedResult<Transaction>> call({
    TransactionFilters? filters,
    int page = 1,
    int pageSize = 50,
  }) => _repository.getTransactions(
    filters: filters, page: page, pageSize: pageSize,
  );
}
```

---

## Category Use-Cases

### GetCategories

```dart
class GetCategories {
  final CategoryRepository _repository;
  const GetCategories(this._repository);
  Future<List<Category>> call() => _repository.getCategories();
}
```

### CreateCategory

```dart
/// Validates:
///   - name non-empty, max 100 chars
///   - colour is valid #RRGGBB hex (if provided)
/// Throws [CategoryNameExistsException] if name is duplicate.
class CreateCategory {
  final CategoryRepository _repository;
  const CreateCategory(this._repository);
  Future<Category> call(CategoryInput input) async { ... }
}
```

### UpdateCategory

```dart
/// Same validation as CreateCategory.
/// Throws [SystemCategoryException] for built-in categories.
class UpdateCategory { ... }
```

### DeleteCategory

```dart
/// Reassigns linked transactions to Uncategorized before deleting.
/// Throws [SystemCategoryException] for built-in categories.
class DeleteCategory { ... }
```

---

## Report Use-Cases

### GetReportSummary

```dart
// lib/features/reports/domain/usecases/get_report_summary.dart

/// Calculates period boundaries from [referenceDate] and [period],
/// then fetches totals from ReportRepository.
///
/// Period boundaries:
///   daily:   00:00:00 – 23:59:59 of referenceDate
///   weekly:  Monday – Sunday of ISO week containing referenceDate
///   monthly: 1st – last day of month containing referenceDate
class GetReportSummary {
  final ReportRepository _repository;
  const GetReportSummary(this._repository);

  Future<ReportSummary> call({
    required ReportPeriod period,
    required DateTime referenceDate,
  }) => _repository.getSummary(period: period, referenceDate: referenceDate);
}
```

### GetCategoryBreakdown

```dart
class GetCategoryBreakdown {
  final ReportRepository _repository;
  const GetCategoryBreakdown(this._repository);

  Future<List<CategoryBreakdown>> call({
    required ReportPeriod period,
    required DateTime referenceDate,
  }) => _repository.getCategoryBreakdown(
    period: period, referenceDate: referenceDate,
  );
}
```

---

## Export Use-Case

### ExportToCsv

```dart
// lib/features/export/domain/usecases/export_to_csv.dart

/// Behaviour:
///   - Fetches ALL matching transactions (no pagination) via TransactionRepository
///   - Serialises to CSV with UTF-8 BOM
///   - Writes to OS temp dir as expense-tracker-YYYY-MM-DD.csv
///   - Returns the absolute file path for the caller to share
///
/// Throws [EmptyExportException] if no transactions match the filters.
class ExportToCsv {
  final ExportRepository _repository;
  const ExportToCsv(this._repository);

  Future<String> call({TransactionFilters? filters}) =>
      _repository.exportToCsv(filters: filters);
}
```

---

## Validation Domain Logic

```dart
// lib/shared/domain/validators.dart — shared validation utilities

class TransactionValidator {
  static void validate(TransactionInput input) {
    if (input.amount <= 0)       throw ValidationException('amount', 'Amount must be greater than 0');
    if (input.date.isEmpty)      throw ValidationException('date',   'Date is required');
    if (!_isValidDate(input.date)) throw ValidationException('date', 'Enter a valid date');
    if (input.note != null && input.note!.length > 500)
      throw ValidationException('note', 'Note cannot exceed 500 characters');
  }
}

class CategoryValidator {
  static void validate(CategoryInput input) {
    if (input.name.trim().isEmpty) throw ValidationException('name', 'Category name is required');
    if (input.name.length > 100)   throw ValidationException('name', 'Category name too long');
    if (input.colour != null && !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(input.colour!))
      throw ValidationException('colour', 'Enter a valid colour code (e.g. #FF5733)');
  }
}

class ValidationException implements Exception {
  final String field;
  final String message;
  const ValidationException(this.field, this.message);
}

class EmptyExportException implements Exception {}
```

---

## Riverpod Provider Graph (sketch)

```
// Dependency injection wiring — illustrative, not exhaustive

final databaseHelperProvider = Provider<DatabaseHelper>(...);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(ref.watch(databaseHelperProvider)),
);

final createTransactionProvider = Provider(
  (ref) => CreateTransaction(ref.watch(transactionRepositoryProvider)),
);

final getTransactionsProvider = Provider(
  (ref) => GetTransactions(ref.watch(transactionRepositoryProvider)),
);

// State notifiers per screen — e.g.:
final transactionListProvider = StateNotifierProvider<TransactionListNotifier, AsyncValue<PaginatedResult<Transaction>>>(
  (ref) => TransactionListNotifier(ref.watch(getTransactionsProvider)),
);
```
