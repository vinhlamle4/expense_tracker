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
  /// Exports [transactions] to a CSV file in the app Documents directory.
  /// [categories] is used to resolve category names from ids.
  /// Returns the [File] on success; throws [ExportException] on failure.
  /// Cleans up partial output on error.
  static Future<File> exportToCsv({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
  }) async {
    final categoryMap = {for (final c in categories) c.id: c.name};
    final dateFormat = DateFormat('yyyy-MM-dd');

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Category', 'Amount', 'Note'], // header
      ...transactions.map((t) => [
            dateFormat.format(t.date),
            t.isIncome ? 'Income' : 'Expense',
            categoryMap[t.categoryId] ?? 'Uncategorized',
            t.amount.toStringAsFixed(0),
            t.note,
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/expense_tracker_$timestamp.csv');

    try {
      await file.writeAsString(csvString, flush: true);
      return file;
    } catch (e) {
      // Clean up partial file on failure.
      if (await file.exists()) await file.delete();
      throw ExportException('Failed to write CSV: $e');
    }
  }
}

