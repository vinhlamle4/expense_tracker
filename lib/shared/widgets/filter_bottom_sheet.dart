import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../data/models/category_model.dart';
import '../providers/filter_providers.dart';

Future<void> showFilterBottomSheet(
  BuildContext context, {
  required Map<String, CategoryModel> categoryMap,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FilterBottomSheet(categoryMap: categoryMap),
  );
}

class FilterBottomSheet extends HookConsumerWidget {
  const FilterBottomSheet({super.key, required this.categoryMap});

  final Map<String, CategoryModel> categoryMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final currentRange = ref.watch(dateRangeFilterProvider);
    final currentCats = ref.watch(categoryFilterProvider);
    final localCats = useState<List<String>>(List.from(currentCats));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Text('Filter', style: tt.titleLarge),
            const Spacer(),
            TextButton(
              onPressed: () {
                ref.read(dateRangeFilterProvider.notifier).state = null;
                ref.read(categoryFilterProvider.notifier).state = const [];
                localCats.value = const [];
              },
              child: const Text('Clear All'),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Date range ───────────────────────────────────────────────
          Text('Date Range', style: tt.labelLarge),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(currentRange == null
                ? 'Select range'
                : '${_fmt(currentRange.start)} → ${_fmt(currentRange.end)}'),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: currentRange,
              );
              if (picked != null) {
                ref.read(dateRangeFilterProvider.notifier).state = picked;
              }
            },
          ),
          if (currentRange != null)
            TextButton(
              onPressed: () =>
                  ref.read(dateRangeFilterProvider.notifier).state = null,
              child: const Text('Clear date range'),
            ),
          const SizedBox(height: 16),

          // ── Category ─────────────────────────────────────────────────
          Text('Category', style: tt.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categoryMap.entries
                .where((e) => e.key != 'uncategorized')
                .map((e) {
              final cat = e.value;
              final sel = localCats.value.contains(cat.id);
              return FilterChip(
                label: Text(cat.name),
                selected: sel,
                onSelected: (v) {
                  final next = List<String>.from(localCats.value);
                  if (v) {
                    next.add(cat.id);
                  } else {
                    next.remove(cat.id);
                  }
                  localCats.value = next;
                  ref.read(categoryFilterProvider.notifier).state = next;
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

