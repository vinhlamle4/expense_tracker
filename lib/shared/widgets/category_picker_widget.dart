import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/category_model.dart';
import '../providers/category_providers.dart';

class CategoryPickerWidget extends ConsumerWidget {
  const CategoryPickerWidget({
    super.key,
    required this.isIncome,
    required this.onSelected,
    this.selectedId,
  });

  final bool isIncome;
  final String? selectedId;
  final ValueChanged<CategoryModel> onSelected;

  // Expense slugs pre-seeded by CategoryRepository.seedDefaults()
  static const _expenseIds = {
    'food', 'transport', 'shopping', 'healthcare', 'entertainment',
    'education', 'other_expense',
  };
  static const _incomeIds = {'salary', 'freelance', 'other_income'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider);

    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (cats) {
        final filtered = cats.where((c) {
          if (c.id == 'uncategorized') return false;
          final isDefaultIncome = _incomeIds.contains(c.id);
          final isDefaultExpense = _expenseIds.contains(c.id);
          final isCustom = !isDefaultIncome && !isDefaultExpense;
          if (isIncome) return isDefaultIncome || isCustom;
          return isDefaultExpense || isCustom;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: filtered.map((cat) {
                final isSelected = cat.id == selectedId;
                final catColor = Color(cat.colorValue);
                return Semantics(
                  label: cat.name,
                  selected: isSelected,
                  child: FilterChip(
                    avatar: Icon(
                      IconData(
                        int.parse(cat.icon, radix: 16),
                        fontFamily: 'MaterialIcons',
                      ),
                      size: 18,
                      color: isSelected ? cs.onSecondaryContainer : catColor,
                    ),
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (_) => onSelected(cat),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

