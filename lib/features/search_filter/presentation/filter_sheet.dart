import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/category_providers.dart';
import '../../../shared/models/transaction_type.dart';
import 'providers/filter_provider.dart';

/// Shows the filter bottom sheet and updates [filterProvider] on Apply.
Future<void> showFilterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: const _FilterSheetContent(),
    ),
  );
}

class _FilterSheetContent extends ConsumerStatefulWidget {
  const _FilterSheetContent();

  @override
  ConsumerState<_FilterSheetContent> createState() =>
      _FilterSheetContentState();
}

class _FilterSheetContentState extends ConsumerState<_FilterSheetContent> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  TransactionType? _type;
  int? _categoryId;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final current = ref.read(filterProvider);
    _fromController.text = current.dateFrom ?? '';
    _toController.text = current.dateTo ?? '';
    _type = current.type;
    _categoryId = current.categoryId;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () {
                  ref.read(filterProvider.notifier).clearAll();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fromController,
                  decoration: const InputDecoration(
                    labelText: 'From (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _dateError = null),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _toController,
                  decoration: const InputDecoration(
                    labelText: 'To (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _dateError = null),
                ),
              ),
            ],
          ),
          if (_dateError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _dateError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),

          // Type
          SegmentedButton<TransactionType?>(
            segments: const [
              ButtonSegment(value: null, label: Text('All')),
              ButtonSegment(
                  value: TransactionType.expense, label: Text('Expense')),
              ButtonSegment(
                  value: TransactionType.income, label: Text('Income')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 12),

          // Category
          categoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (cats) => DropdownButtonFormField<int?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...cats.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton(
            onPressed: _apply,
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  bool _validate() {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    if (from.isNotEmpty && to.isNotEmpty) {
      try {
        final df = DateTime.parse(from);
        final dt = DateTime.parse(to);
        if (dt.isBefore(df)) {
          setState(() => _dateError = '"To" date must be after "From" date');
          return false;
        }
      } catch (_) {
        setState(() => _dateError = 'Invalid date format (YYYY-MM-DD)');
        return false;
      }
    }
    return true;
  }

  void _apply() {
    if (!_validate()) return;
    final notifier = ref.read(filterProvider.notifier);
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    notifier.updateDateRange(
      dateFrom: from.isEmpty ? null : from,
      dateTo: to.isEmpty ? null : to,
    );
    notifier.updateType(_type);
    notifier.updateCategoryId(_categoryId);
    Navigator.pop(context);
  }
}
