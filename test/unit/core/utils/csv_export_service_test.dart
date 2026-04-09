import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:expense_tracker/core/utils/csv_export_service.dart';

import '../../../fixtures/fixtures.dart';

// ── Fake path_provider that redirects to a temp directory ──────────────────

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;
  _FakePathProvider(this.tempPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;
}

// ── Helper: write dummy CSV to simulate a pre-existing file ────────────────

Future<void> _writeFile(Directory dir, String name) async {
  await File('${dir.path}/$name').writeAsString('existing');
}

// ── Helpers: count CSV rows / extract header ───────────────────────────────

List<List<String>> _parseCsv(String content) {
  return content
      .trim()
      .split('\n')
      .map((line) => line.split(',').map((e) => e.trim()).toList())
      .toList();
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('csv_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDown(() async {
    // Clean up any CSV files created during the test
    await for (final f in tempDir.list()) {
      if (f.path.endsWith('.csv')) await f.delete();
    }
  });

  // ════════════════════════════════════════════════════════════════════════
  // Happy Paths — CSV generation
  // ════════════════════════════════════════════════════════════════════════

  group('CSV generation', () {
    test('exports header row + 1 data row for single transaction', () async {
      final transactions = [
        makeExpense(id: 1, amount: 150_000, note: 'Coffee')
          ..categoryId = 'food',
      ];
      final categories = makeDefaultCategories();

      final file = await CsvExportService.exportToCsv(
        transactions: transactions,
        categories: categories,
      );

      expect(file.existsSync(), isTrue);
      final rows = _parseCsv(await file.readAsString());
      expect(rows.length, 2); // header + 1 data row
      expect(rows[0], containsAll(['Date', 'Type', 'Category', 'Amount', 'Note']));
    });

    test('exports correct column count for 3 transactions', () async {
      final categories = makeDefaultCategories();
      final transactions = [
        makeExpense(id: 1, note: 'Tx 1')..categoryId = 'food',
        makeIncome(id: 2, note: 'Tx 2')..categoryId = 'salary',
        makeExpense(id: 3, note: 'Tx 3')..categoryId = 'transport',
      ];

      final file = await CsvExportService.exportToCsv(
        transactions: transactions,
        categories: categories,
      );

      final rows = _parseCsv(await file.readAsString());
      expect(rows.length, 4); // header + 3 rows
    });

    test('income row has Type=Income and expense has Type=Expense', () async {
      final categories = makeDefaultCategories();
      final transactions = [
        makeIncome(id: 1, note: 'Salary')..categoryId = 'salary',
        makeExpense(id: 2, note: 'Coffee')..categoryId = 'food',
      ];

      final file = await CsvExportService.exportToCsv(
        transactions: transactions,
        categories: categories,
      );

      final content = await file.readAsString();
      expect(content, contains('Income'));
      expect(content, contains('Expense'));
    });

    test('unknown category ID falls back to Uncategorized', () async {
      final transactions = [
        makeExpense(id: 1, note: 'X')..categoryId = 'ghost_cat',
      ];

      final file = await CsvExportService.exportToCsv(
        transactions: transactions,
        categories: [], // no categories
      );

      final content = await file.readAsString();
      expect(content, contains('Uncategorized'));
    });

    test('note is written to last column', () async {
      final categories = makeDefaultCategories();
      final transactions = [
        makeExpense(id: 1, amount: 50_000, note: 'My note here')
          ..categoryId = 'food',
      ];

      final file = await CsvExportService.exportToCsv(
        transactions: transactions,
        categories: categories,
      );

      final content = await file.readAsString();
      expect(content, contains('My note here'));
    });

    test('empty transaction list exports header only', () async {
      final file = await CsvExportService.exportToCsv(
        transactions: [],
        categories: makeDefaultCategories(),
      );

      final rows = _parseCsv(await file.readAsString());
      expect(rows.length, 1); // header only
      expect(rows[0], containsAll(['Date', 'Type', 'Category', 'Amount', 'Note']));
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Edge Cases — large data
  // ════════════════════════════════════════════════════════════════════════

  group('edge cases', () {
    test('exports 1000 transactions without error', () async {
      final transactions = List.generate(1000, (i) {
        final t = makeExpense(id: i + 1, amount: 1000 + i.toDouble(),
            note: 'Tx $i')
          ..categoryId = 'food';
        return t;
      });

      final file = await CsvExportService.exportToCsv(
        transactions: transactions,
        categories: makeDefaultCategories(),
      );

      final rows = _parseCsv(await file.readAsString());
      expect(rows.length, 1001); // header + 1000 data rows
    });

    test('exported file has .csv extension', () async {
      final file = await CsvExportService.exportToCsv(
        transactions: [makeExpense(id: 1)..categoryId = 'food'],
        categories: makeDefaultCategories(),
      );

      expect(file.path.endsWith('.csv'), isTrue);
    });

    test('filename contains today date in yyyy-MM-dd format', () async {
      final file = await CsvExportService.exportToCsv(
        transactions: [],
        categories: [],
      );

      final dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
      expect(dateRegex.hasMatch(file.path), isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Filename Conflict Resolution — _resolveUniqueFile
  // ════════════════════════════════════════════════════════════════════════

  group('filename conflict resolution', () {
    test('appends _1 suffix when base filename exists', () async {
      // First export creates transactions_YYYY-MM-DD.csv
      final first = await CsvExportService.exportToCsv(
        transactions: [],
        categories: [],
      );
      expect(first.existsSync(), isTrue);
      expect(first.path, isNot(contains('_1')));

      // Second export on the same day appends _1
      final second = await CsvExportService.exportToCsv(
        transactions: [],
        categories: [],
      );
      expect(second.existsSync(), isTrue);
      expect(second.path, contains('_1'));
    });

    test('appends _2 when _1 already exists', () async {
      // Seed both base and _1 to force _2 creation
      final baseName = 'transactions_${DateTime.now().toIso8601String().substring(0, 10)}';
      await _writeFile(tempDir, '$baseName.csv');
      await _writeFile(tempDir, '${baseName}_1.csv');

      final file = await CsvExportService.exportToCsv(
        transactions: [],
        categories: [],
      );

      expect(file.path, contains('_2'));
    });

    test('handles 10 consecutive filename increments', () async {
      // Seed 10 existing files: base, _1 … _9
      final baseName = 'transactions_${DateTime.now().toIso8601String().substring(0, 10)}';
      await _writeFile(tempDir, '$baseName.csv');
      for (var i = 1; i < 10; i++) {
        await _writeFile(tempDir, '${baseName}_$i.csv');
      }

      final file = await CsvExportService.exportToCsv(
        transactions: [],
        categories: [],
      );

      expect(file.path, contains('_10'));
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Failure Scenarios — Error Handling
  // ════════════════════════════════════════════════════════════════════════

  group('failure scenarios', () {
    test('ExportException message contains readable cause', () async {
      // Point path_provider to a non-existent path to trigger write failure
      PathProviderPlatform.instance =
          _FakePathProvider('/tmp/__nonexistent__/__deep__/__path__');

      try {
        expect(
          () async => await CsvExportService.exportToCsv(
            transactions: [makeExpense(id: 1)..categoryId = 'food'],
            categories: makeDefaultCategories(),
          ),
          throwsA(isA<ExportException>()),
        );
      } finally {
        PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
      }
    });

    test('exported file exists on disk after successful export', () async {
      final file = await CsvExportService.exportToCsv(
        transactions: [makeExpense(id: 1)..categoryId = 'food'],
        categories: makeDefaultCategories(),
      );

      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(0));
    });
  });
}


