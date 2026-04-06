import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';

class ExportException implements Exception {
  ExportException(this.message);
  final String message;
  @override
  String toString() => 'ExportException: $message';
}

abstract final class CsvExportService {
  /// Exports [transactions] to a CSV file in the device's public **Downloads**
  /// folder (Android) or the app's Documents directory (iOS — accessible via
  /// the Files app when `UIFileSharingEnabled = true` in Info.plist).
  ///
  /// Filename format: `transactions_yyyy-MM-dd.csv`.
  /// If a file with that name already exists, `_1`, `_2`, … is appended
  /// to avoid silent overwrites.
  ///
  /// Returns the saved [File] on success.
  /// Throws [ExportException] on failure and cleans up any partial output.
  static Future<File> exportToCsv({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
  }) async {
    final categoryMap = {for (final c in categories) c.id: c.name};
    final dateFormat = DateFormat('yyyy-MM-dd');

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Category', 'Amount', 'Note'], // header
      ...transactions.map(
        (t) => [
          dateFormat.format(t.date),
          t.isIncome ? 'Income' : 'Expense',
          categoryMap[t.categoryId] ?? 'Uncategorized',
          t.amount.toStringAsFixed(0),
          t.note,
        ],
      ),
    ];

    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await _resolveExportDirectory();
    final baseName = 'transactions_${dateFormat.format(DateTime.now())}';
    final file = _resolveUniqueFile(dir, baseName);

    try {
      await file.writeAsString(csvString, flush: true);
      return file;
    } catch (e) {
      // Clean up any partial file on failure.
      if (await file.exists()) await file.delete();
      throw ExportException('Failed to write CSV: $e');
    }
  }

  // ── Path resolution ──────────────────────────────────────────────────────

  /// Resolves the export target directory:
  ///
  /// * **Android** — the public `Download` folder at the root of external
  ///   storage (e.g. `/storage/emulated/0/Download`). Constructed by stripping
  ///   the app-private suffix from [getExternalStorageDirectory]'s path.
  ///   Falls back to [getApplicationDocumentsDirectory] if external storage
  ///   is unavailable.
  ///
  /// * **iOS** — [getApplicationDocumentsDirectory], which is surfaced in the
  ///   system Files app when `UIFileSharingEnabled = true` in Info.plist.
  static Future<Directory> _resolveExportDirectory() async {
    if (Platform.isAndroid) {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        // extDir.path  →  /storage/emulated/0/Android/data/<pkg>/files
        // We split on '/Android' to get the root storage path, then append
        // the standard public Download directory.
        final basePath = extDir.path.split('/Android').first;
        final downloadDir = Directory('$basePath/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }
    }
    // iOS and Android fallback.
    return getApplicationDocumentsDirectory();
  }

  /// Returns a [File] whose name is unique in [dir].
  ///
  /// If `<baseName>.csv` already exists, appends `_1`, `_2`, … until a free
  /// name is found (e.g. `transactions_2026-04-06_2.csv`).
  static File _resolveUniqueFile(Directory dir, String baseName) {
    var candidate = File('${dir.path}/$baseName.csv');
    if (!candidate.existsSync()) return candidate;
    var index = 1;
    do {
      candidate = File('${dir.path}/${baseName}_$index.csv');
      index++;
    } while (candidate.existsSync());
    return candidate;
  }
}
