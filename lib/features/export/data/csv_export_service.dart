import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../transactions/domain/entities/transaction.dart';

class CsvExportService {
  static const _headers = [
    'Date',
    'Type',
    'Category',
    'Amount',
    'Currency',
    'Note',
    'Created At',
  ];

  /// UTF-8 BOM prefix for Excel compatibility.
  static const _bom = '\uFEFF';

  final _dateFormat = DateFormat('yyyy-MM-dd');

  Future<String> writeToFile(List<Transaction> transactions) async {
    final rows = <List<dynamic>>[
      _headers,
      ...transactions.map(_toRow),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await _resolveDirectory();
    final now = DateTime.now();
    final fileName =
        'expense_tracker_${_dateFormat.format(now)}_${now.millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString('$_bom$csv');
    return file.path;
  }

  /// On Android, saves to the app-specific external storage directory so the
  /// file is visible in file-manager apps without requiring special permissions
  /// (scoped storage, API 29+). Falls back to internal documents directory.
  /// On iOS, saves to the app documents directory which is exposed to the
  /// Files app when [UIFileSharingEnabled] is set in Info.plist.
  Future<Directory> _resolveDirectory() async {
    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectory();
      if (external != null) return external;
    }
    return getApplicationDocumentsDirectory();
  }

  List<dynamic> _toRow(Transaction t) {
    return [
      t.date,
      t.type.value,
      t.categoryName,
      t.amount,
      'VND',
      t.note ?? '',
      t.createdAt.toIso8601String(),
    ];
  }
}
