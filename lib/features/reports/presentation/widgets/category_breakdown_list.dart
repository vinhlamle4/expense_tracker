import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category_breakdown.dart';

class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({super.key, required this.items});

  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _BreakdownTile(item: item);
      },
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  const _BreakdownTile({required this.item});

  final CategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    final colour = _parseHex(item.categoryColour);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colour.withAlpha(30),
                child: Icon(_iconData(item.categoryIcon),
                    size: 16, color: colour),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.categoryName,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text(CurrencyFormatter.format(item.total),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Semantics(
            label:
                '${item.categoryName}: ${item.percentage.toStringAsFixed(1)} percent',
            child: LinearProgressIndicator(
              value: item.percentage / 100,
              backgroundColor:
                  colorScheme.surfaceContainerHighest,
              color: colour,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
      return Color(value);
    } catch (_) {
      return const Color(0xFF1976D2);
    }
  }

  IconData _iconData(String name) {
    const map = <String, IconData>{
      'restaurant': Icons.restaurant,
      'directions_bus': Icons.directions_bus,
      'shopping_bag': Icons.shopping_bag,
      'local_hospital': Icons.local_hospital,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'attach_money': Icons.attach_money,
      'more_horiz': Icons.more_horiz,
      'category': Icons.category,
    };
    return map[name] ?? Icons.circle;
  }
}
