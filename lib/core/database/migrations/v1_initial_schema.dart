const String createCategoriesTable = '''
  CREATE TABLE IF NOT EXISTS categories (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL UNIQUE,
    icon       TEXT,
    colour     TEXT,
    is_system  INTEGER NOT NULL DEFAULT 0,
    created_at TEXT    NOT NULL,
    updated_at TEXT    NOT NULL
  )
''';

const String createTransactionsTable = '''
  CREATE TABLE IF NOT EXISTS transactions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    amount      INTEGER NOT NULL CHECK(amount > 0),
    type        TEXT    NOT NULL CHECK(type IN ('income', 'expense')),
    category_id INTEGER NOT NULL REFERENCES categories(id),
    date        TEXT    NOT NULL,
    note        TEXT,
    created_at  TEXT    NOT NULL,
    updated_at  TEXT    NOT NULL
  )
''';

const String createIndexDate =
    'CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC)';

const String createIndexCategory =
    'CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id)';

const String createIndexTypeDate =
    'CREATE INDEX IF NOT EXISTS idx_transactions_type_date ON transactions(type, date)';
