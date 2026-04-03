import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/export/data/csv_export_service.dart';
import '../../features/export/data/repositories/export_repository_impl.dart';
import '../../features/export/domain/repositories/export_repository.dart';
import '../../features/export/domain/usecases/export_to_csv.dart';
import 'transaction_providers.dart';

final csvExportServiceProvider = Provider<CsvExportService>(
  (_) => CsvExportService(),
);

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepositoryImpl(
    ref.read(transactionRepositoryProvider),
    ref.read(csvExportServiceProvider),
  );
});

final exportToCsvProvider = Provider<ExportToCsv>((ref) {
  return ExportToCsv(ref.read(exportRepositoryProvider));
});
