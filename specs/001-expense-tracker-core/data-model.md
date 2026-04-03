# Data Model: Expense Tracker — 001-expense-tracker-core

**Generated**: 2026-04-03 | **Phase**: 1  
**Storage**: SQLite (sqflite) | **Amount representation**: integer minor units

---

## Entities

### Category

Represents a classification for transactions. Built-in categories (`is_system = 1`) cannot be deleted or renamed.

**SQLite table**: `categories`

| Column | SQLite Type | Dart Type | Required | Constraints | Notes |
|--------|------------|-----------|----------|-------------|-------|
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | `int` | System | PK | Auto-assigned |
| `name` | `TEXT NOT NULL` | `String` | Yes | UNIQUE, max 100 chars | e.g., `"Food"` |
| `icon` | `TEXT` | `String?` | No | — | Material icon name, e.g., `"restaurant"` |
| `colour` | `TEXT` | `String?` | No | `#RRGGBB` format | e.g., `"#FF5733"` |
| `is_system` | `INTEGER NOT NULL DEFAULT 0` | `bool` | System | `0` or `1` | `1` = built-in, undeletable |
| `created_at` | `TEXT NOT NULL` | `DateTime` | System | ISO 8601 local | e.g., `"2026-04-03T08:00:00"` |
| `updated_at` | `TEXT NOT NULL` | `DateTime` | System | ISO 8601 local | Updated on every edit |

**Default / built-in categories** (seeded on first launch, `is_system = 1`):

| id | name | icon | colour |
|----|------|------|--------|
| 1 | Food | restaurant | #FF7043 |
| 2 | Transport | directions_car | #42A5F5 |
| 3 | Shopping | shopping_bag | #AB47BC |
| 4 | Health | local_hospital | #26A69A |
| 5 | Entertainment | movie | #FFA726 |
| 6 | Bills | receipt_long | #78909C |
| 7 | Income | payments | #66BB6A |
| 8 | Uncategorized | help_outline | #BDBDBD |

**Validation rules**:
- `name`: required, non-empty, max 100 chars, unique across all categories.
- Cannot delete or rename a category where `is_system = 1`.
- `colour`: if provided, must match regex `^#[0-9A-Fa-f]{6}$`.

---

### Transaction

A single financial event — either income or an expense.

**SQLite table**: `transactions`

| Column | SQLite Type | Dart Type | Required | Constraints | Notes |
|--------|------------|-----------|----------|-------------|-------|
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | `int` | System | PK | Auto-assigned |
| `amount` | `INTEGER NOT NULL` | `int` | Yes | > 0 | Minor currency units (VND = whole đồng) |
| `type` | `TEXT NOT NULL` | `TransactionType` | Yes | `'income'` or `'expense'` | Enum stored as string |
| `category_id` | `INTEGER NOT NULL` | `int` | Yes | FK → `categories.id` | Reassigned to Uncategorized (id=8) on category delete |
| `date` | `TEXT NOT NULL` | `String` | Yes | `YYYY-MM-DD`, ≥ `1970-01-01` | User-entered date |
| `note` | `TEXT` | `String?` | No | max 500 chars | Free-text memo |
| `created_at` | `TEXT NOT NULL` | `DateTime` | System | ISO 8601 local | Set on insert |
| `updated_at` | `TEXT NOT NULL` | `DateTime` | System | ISO 8601 local | Updated on every edit |

**Validation rules**:
- `amount`: required, integer, > 0.
- `type`: required, must be `'income'` or `'expense'`.
- `category_id`: required, must reference an existing category.
- `date`: required, valid date `YYYY-MM-DD`, ≥ `1970-01-01`.
- `note`: optional, max 500 characters.

---

## Enums

```dart
enum TransactionType {
  income,   // stored as 'income'
  expense,  // stored as 'expense'
}
```

---

## Relationships

```
Category (1) ────< Transaction (many)
  categories.id ──── transactions.category_id (FK)
```

- A category can have zero or more transactions.
- A transaction belongs to exactly one category.
- **On category delete**: UPDATE transactions SET category_id = 8 (Uncategorized) WHERE category_id = deleted_id. Then DELETE category.
- The `Uncategorized` category (id = 8, `is_system = 1`) cannot be deleted.

---

## State Transitions

### Transaction Lifecycle

```
[form open] → create → [saved, id assigned]
                            ↓
                       [edit] → update → [saved, updated_at refreshed]
                            ↓
                       [delete confirm] → delete → [removed from DB]
```

### Category Lifecycle

```
[category list] → create → [saved]
                      ↓
                 [edit name/icon/colour] → update
                      ↓
                 [delete] ─→ [if is_system=1] → BLOCKED
                         └→ [if is_system=0] → reassign transactions → delete
```

---

## SQLite Schema (DDL)

```sql
CREATE TABLE IF NOT EXISTS categories (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL UNIQUE,
  icon       TEXT,
  colour     TEXT,
  is_system  INTEGER NOT NULL DEFAULT 0,
  created_at TEXT    NOT NULL,
  updated_at TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  amount      INTEGER NOT NULL CHECK(amount > 0),
  type        TEXT    NOT NULL CHECK(type IN ('income', 'expense')),
  category_id INTEGER NOT NULL REFERENCES categories(id),
  date        TEXT    NOT NULL,
  note        TEXT,
  created_at  TEXT    NOT NULL,
  updated_at  TEXT    NOT NULL
);

-- Index for common query pattern: list sorted by date descending
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC);

-- Index for report aggregation by category
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);

-- Index for combined filter queries
CREATE INDEX IF NOT EXISTS idx_transactions_type_date ON transactions(type, date);
```

**Database version**: 1  
**Migration strategy**: Sequential versioned scripts in `lib/core/database/migrations/`. Each migration is a plain SQL string executed inside `onUpgrade`. Version tracked by SQLite `PRAGMA user_version`.

---

## Query Patterns

### List Transactions (paginated, filtered)

```sql
SELECT t.*, c.name as category_name, c.icon, c.colour
FROM transactions t
JOIN categories c ON t.category_id = c.id
WHERE
  (t.date >= :dateFrom OR :dateFrom IS NULL) AND
  (t.date <= :dateTo   OR :dateTo   IS NULL) AND
  (t.type  = :type     OR :type     IS NULL) AND
  (t.category_id = :categoryId OR :categoryId IS NULL) AND
  (t.amount >= :amountMin OR :amountMin IS NULL) AND
  (t.amount <= :amountMax OR :amountMax IS NULL) AND
  (t.note LIKE '%' || :keyword || '%' OR :keyword IS NULL)
ORDER BY t.date DESC, t.created_at DESC
LIMIT :pageSize OFFSET :offset;
```

### Report Summary (monthly example)

```sql
SELECT
  SUM(CASE WHEN type = 'income'  THEN amount ELSE 0 END) AS total_income,
  SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS total_expenses
FROM transactions
WHERE date >= :periodStart AND date <= :periodEnd;
```

### Category Breakdown (expenses only)

```sql
SELECT
  c.id,
  c.name,
  SUM(t.amount) AS total,
  ROUND(100.0 * SUM(t.amount) / :totalExpenses, 1) AS percentage
FROM transactions t
JOIN categories c ON t.category_id = c.id
WHERE t.type = 'expense'
  AND t.date >= :periodStart
  AND t.date <= :periodEnd
GROUP BY c.id, c.name
ORDER BY total DESC;
```

---

## Domain Entities (Dart)

```dart
// lib/features/transactions/domain/entities/transaction.dart
class Transaction {
  final int id;
  final int amount;             // minor currency units
  final TransactionType type;
  final int categoryId;
  final String categoryName;    // denormalized for display only
  final String date;            // YYYY-MM-DD
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// lib/features/categories/domain/entities/category.dart
class Category {
  final int id;
  final String name;
  final String? icon;
  final String? colour;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Note**: `categoryName` on `Transaction` is populated by the JOIN in the list query and is *not* stored in the DB. The Data-layer `TransactionModel` maps both columns.

---

## Post-Design Constitution Re-check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Feature Modularity | ✅ PASS | Each entity maps to its own feature module |
| II. Local-First Data | ✅ PASS | All tables in SQLite; no remote fields |
| III. Clean Architecture | ✅ PASS | DDL ↔ Model ↔ Repository interface ↔ Use-case ↔ Entity layered correctly |
| IV. Test Coverage | ✅ PASS | All query patterns are unit-testable via repository interface |
| V. Simplicity & YAGNI | ✅ PASS | 2 tables, 3 indexes — minimal schema for confirmed requirements |

**GATE RESULT: ALL PASS — proceed to contracts.**
