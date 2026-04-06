import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/providers/category_providers.dart';
import '../../../shared/providers/transaction_providers.dart';
import '../../../shared/widgets/confirm_dialog_widget.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/filter_bottom_sheet.dart';
import 'add_edit_transaction_sheet.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(transactionVMProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final categoryMap = categoriesAsync.valueOrNull != null
        ? {for (final c in categoriesAsync.valueOrNull!) c.id: c}
        : <String, CategoryModel>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                const Expanded(child: TransactionSearchBar()),
                const SizedBox(width: 8),
                _FilterButton(categoryMap: categoryMap),
              ],
            ),
          ),
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (state.filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long,
                      size: 72,
                      color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    state.all.isEmpty
                        ? 'No transactions yet.\nTap + to add one!'
                        : 'No results match your search.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = state.filtered[i];
              return _TransactionTile(
                transaction: t,
                category: categoryMap[t.categoryId],
                onEdit: () => showAddEditTransactionSheet(context, existing: t),
                onDelete: () async {
                  final confirmed = await ConfirmDialogWidget.show(
                    context,
                    title: 'Delete Transaction',
                    content: 'This action cannot be undone.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed) {
                    await ref
                        .read(transactionVMProvider.notifier)
                        .deleteTransaction(t.id);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Semantics(
        label: 'Add transaction',
        child: FloatingActionButton(
          onPressed: () => showAddEditTransactionSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ── Private widgets ────────────────────────────────────────────────────────

class _FilterButton extends ConsumerWidget {
  const _FilterButton({required this.categoryMap});
  final Map<String, CategoryModel> categoryMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.filledTonal(
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filter',
      onPressed: () => showFilterBottomSheet(context, categoryMap: categoryMap),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cat = category;
    final amountColor =
        transaction.isIncome ? cs.primary : cs.error;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return ConfirmDialogWidget.show(
          context,
          title: 'Delete Transaction',
          content: 'This action cannot be undone.',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        child: ListTile(
          onTap: onEdit,
          leading: CircleAvatar(
            backgroundColor: cat != null
                ? Color(cat.colorValue).withAlpha(40)
                : cs.surfaceContainerHighest,
            child: cat != null
                ? Icon(
                    IconData(
                      int.parse(cat.icon, radix: 16),
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Color(cat.colorValue),
                    size: 20,
                  )
                : const Icon(Icons.category_outlined, size: 20),
          ),
          title: Text(
            transaction.note.isNotEmpty ? transaction.note : cat?.name ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DateFormat('dd MMM yyyy').format(transaction.date),
            style: tt.bodySmall,
          ),
          trailing: Text(
            '${transaction.isIncome ? '+' : '-'}${_fmt(transaction.amount)}',
            style: tt.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
}
