# Repository Interfaces: Expense Tracker — 001-expense-tracker-core

**Layer**: Domain  
**Generated**: 2026-04-03

These interfaces are the contract that the Data layer MUST implement.
No Flutter imports. No `sqflite` references. Pure Dart.

---

## TransactionRepository

```dart
// lib/features/transactions/domain/repositories/transaction_repository.dart
import '../entities/transaction.dart';
import '../../../shared/models/paginated_result.dart';
import '../../../shared/models/transaction_filters.dart';

abstract class TransactionRepository {
  /// Returns a paginated list of transactions matching [filters].
  /// Results are sorted by date descending, then created_at descending.
  /// [page] is 1-indexed. [pageSize] defaults to 50.
  Future<PaginatedResult<Transaction>> getTransactions({
    TransactionFilters? filters,
    int page = 1,
    int pageSize = 50,
  });

  /// Returns the total count of transactions matching [filters].
  /// Used to compute total pages for pagination.
  Future<int> countTransactions({TransactionFilters? filters});

  /// Creates a new transaction. Returns the created entity with its assigned [id].
  Future<Transaction> createTransaction(TransactionInput input);

  /// Updates an existing transaction identified by [id].
  /// Returns the updated entity.
  /// Throws [TransactionNotFoundException] if no transaction with [id] exists.
  Future<Transaction> updateTransaction(int id, TransactionInput input);

  /// Deletes the transaction with [id].
  /// Throws [TransactionNotFoundException] if no transaction with [id] exists.
  Future<void> deleteTransaction(int id);
}
```

---

## CategoryRepository

```dart
// lib/features/categories/domain/repositories/category_repository.dart
import '../entities/category.dart';

abstract class CategoryRepository {
  /// Returns all categories, system categories first, then custom alphabetically.
  Future<List<Category>> getCategories();

  /// Creates a new custom category. Returns the created entity with its [id].
  /// Throws [CategoryNameExistsException] if name is not unique.
  Future<Category> createCategory(CategoryInput input);

  /// Updates name, icon, or colour of category [id].
  /// Throws [CategoryNotFoundException] if not found.
  /// Throws [SystemCategoryException] if [id] refers to a system category.
  /// Throws [CategoryNameExistsException] if new name conflicts.
  Future<Category> updateCategory(int id, CategoryInput input);

  /// Deletes category [id].
  ///   1. Reassigns all transactions with category_id == [id] to Uncategorized (id = 8).
  ///   2. Deletes the category record.
  /// Throws [SystemCategoryException] if [id] refers to a system category.
  Future<void> deleteCategory(int id);
}
```

---

## ReportRepository

```dart
// lib/features/reports/domain/repositories/report_repository.dart
import '../entities/report_summary.dart';
import '../entities/category_breakdown.dart';
import '../../../shared/models/report_period.dart';

abstract class ReportRepository {
  /// Returns income/expense/net totals for the period containing [referenceDate].
  Future<ReportSummary> getSummary({
    required ReportPeriod period,
    required DateTime referenceDate,
  });

  /// Returns per-category expense breakdown for the period.
  /// Sorted by total amount descending.
  /// Categories with 0 expenses are omitted.
  Future<List<CategoryBreakdown>> getCategoryBreakdown({
    required ReportPeriod period,
    required DateTime referenceDate,
  });
}
```

---

## ExportRepository

```dart
// lib/features/export/domain/repositories/export_repository.dart
import '../../../shared/models/transaction_filters.dart';

abstract class ExportRepository {
  /// Generates a CSV file for transactions matching [filters] (or all if null).
  /// The file is written to the temp directory and its path is returned.
  /// Caller is responsible for sharing / cleaning up the file.
  /// File is named: expense-tracker-YYYY-MM-DD.csv (using today's date).
  Future<String> exportToCsv({TransactionFilters? filters});
}
```

---

## Shared Value Objects

```dart
// lib/shared/models/transaction_filters.dart
class TransactionFilters {
  final String? dateFrom;     // YYYY-MM-DD, inclusive
  final String? dateTo;       // YYYY-MM-DD, inclusive
  final TransactionType? type;
  final int? categoryId;
  final int? amountMin;       // minor units, inclusive
  final int? amountMax;       // minor units, inclusive
  final String? keyword;      // substring match on note field
}

// lib/shared/models/paginated_result.dart
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasMore => page < totalPages;
}

// lib/shared/models/report_period.dart
enum ReportPeriod { daily, weekly, monthly }

// lib/features/transactions/domain/entities/transaction_input.dart
class TransactionInput {
  final int amount;
  final TransactionType type;
  final int categoryId;
  final String date;      // YYYY-MM-DD
  final String? note;
}

// lib/features/categories/domain/entities/category_input.dart
class CategoryInput {
  final String name;
  final String? icon;
  final String? colour;   // #RRGGBB or null
}
```

---

## Domain Exceptions

```dart
// lib/shared/exceptions/domain_exceptions.dart
class TransactionNotFoundException implements Exception {
  final int id;
  TransactionNotFoundException(this.id);
}

class CategoryNotFoundException implements Exception {
  final int id;
  CategoryNotFoundException(this.id);
}

class SystemCategoryException implements Exception {
  final String message;
  SystemCategoryException(this.message);
}

class CategoryNameExistsException implements Exception {
  final String name;
  CategoryNameExistsException(this.name);
}
```

---

## Report Value Objects

```dart
// lib/features/reports/domain/entities/report_summary.dart
class ReportSummary {
  final int totalIncome;    // minor units
  final int totalExpenses;  // minor units
  final int netBalance;     // totalIncome - totalExpenses (can be negative)
  final String periodLabel; // e.g., "April 2026", "Week 14", "03 Apr 2026"
}

// lib/features/reports/domain/entities/category_breakdown.dart
class CategoryBreakdown {
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColour;
  final int total;           // minor units, expense totals only
  final double percentage;   // 0.0 – 100.0, 1 decimal place
}
```
