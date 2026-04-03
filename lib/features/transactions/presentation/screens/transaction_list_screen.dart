import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/export_providers.dart';
import '../../../../core/providers/transaction_providers.dart';
import '../../../../shared/exceptions/domain_exceptions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../search_filter/presentation/filter_sheet.dart';
import '../../../search_filter/presentation/providers/filter_provider.dart';
import '../../../search_filter/presentation/widgets/active_filters_bar.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_list_provider.dart';
import '../widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => showFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Save CSV',
            onPressed: () => _saveCsv(context, ref),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by note…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(filterProvider.notifier)
                              .updateKeyword(null);
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (v) {
                setState(() {});
                ref.read(filterProvider.notifier).updateKeyword(v);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // const DashboardSummary(),
          const ActiveFiltersBar(),
          Expanded(
            child: asyncState.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorState(
                message: 'Failed to load transactions',
                onRetry: () =>
                    ref.read(transactionListProvider.notifier).refresh(),
              ),
              data: (result) => result.isEmpty
                  ? EmptyState(
                      title: ref.read(filterProvider).isEmpty
                          ? 'No transactions yet'
                          : 'No transactions match your filters',
                      subtitle: ref.read(filterProvider).isEmpty
                          ? 'Tap + to add your first transaction'
                          : 'Try adjusting or clearing your filters',
                      icon: Icons.receipt_long_outlined,
                    )
                  : _TransactionList(transactions: result.items, ref: ref),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-transaction-fab',
        onPressed: () => context.pushNamed('add-transaction'),
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _saveCsv(BuildContext context, WidgetRef ref) async {
    final filters = ref.read(filterProvider);
    try {
      final path = await ref.read(exportToCsvProvider).call(filters: filters);
      final fileName = path.split('/').last;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved: $fileName'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () async {
                await Share.shareXFiles(
                  [XFile(path)],
                  subject: 'Expense Tracker Export',
                );
              },
            ),
          ),
        );
      }
    } on EmptyExportException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Nothing to export — add some transactions first')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions, required this.ref});
  final List<Transaction> transactions;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => ListView.separated(
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final t = transactions[index];
          return TransactionTile(
            transaction: t,
            onTap: () => context.pushNamed(
              'edit-transaction',
              pathParameters: {'id': t.id.toString()},
              extra: t,
            ),
            onDelete: () => _confirmDelete(context, ref, t),
          );
        },
      );

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('This transaction will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(deleteTransactionProvider).call(t.id);
      ref.invalidate(transactionListProvider);
    }
  }
}
