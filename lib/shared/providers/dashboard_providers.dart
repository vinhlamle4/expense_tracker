import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/dashboard/viewmodels/dashboard_view_model.dart';

export 'transaction_providers.dart' show transactionVMProvider;

enum DashboardPeriod { day, week, month }

final selectedPeriodProvider =
    StateProvider<DashboardPeriod>((ref) => DashboardPeriod.month);

final dashboardVMProvider =
    NotifierProvider<DashboardViewModel, DashboardSummary>(
  DashboardViewModel.new,
);


