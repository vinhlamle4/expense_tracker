import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_provider.dart';

class ActiveFiltersBar extends ConsumerWidget {
  const ActiveFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);
    if (filters.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[];
    final notifier = ref.read(filterProvider.notifier);

    if (filters.dateFrom != null || filters.dateTo != null) {
      final label = '${filters.dateFrom ?? '...'} – ${filters.dateTo ?? '...'}';
      chips.add(_Chip(
        label: label,
        onDelete: () => notifier.updateDateRange(),
      ));
    }
    if (filters.type != null) {
      chips.add(_Chip(
        label: filters.type!.value,
        onDelete: () => notifier.updateType(null),
      ));
    }
    if (filters.categoryId != null) {
      chips.add(_Chip(
        label: 'Category #${filters.categoryId}',
        onDelete: () => notifier.updateCategoryId(null),
      ));
    }
    if (filters.keyword != null) {
      chips.add(_Chip(
        label: '"${filters.keyword}"',
        onDelete: () => notifier.updateKeyword(null),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          ...chips,
          TextButton(
            onPressed: notifier.clearAll,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onDelete});

  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FilterChip(
          label: Text(label),
          selected: true,
          onSelected: (_) {},
          onDeleted: onDelete,
        ),
      );
}
