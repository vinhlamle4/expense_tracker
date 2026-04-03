import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome
        ? AppTheme.incomeColor(colorScheme)
        : AppTheme.expenseColor(colorScheme);
    final sign = isIncome ? '+' : '-';

    Color? catColour;
    if (transaction.categoryColour != null) {
      catColour = _parseHex(transaction.categoryColour!);
    }

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.errorContainer,
        child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async => onDelete != null,
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: catColour?.withValues(alpha: 0.2) ?? colorScheme.surfaceContainerHighest,
          child: Icon(
            _iconData(transaction.categoryIcon),
            color: catColour ?? colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(transaction.categoryName),
        subtitle: Text(
          transaction.date +
              (transaction.note != null && transaction.note!.isNotEmpty
                  ? ' · ${transaction.note}'
                  : ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '$sign${CurrencyFormatter.format(transaction.amount)}',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: amountColor, fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
      ),
    );
  }

  static Color? _parseHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return null;
    }
  }

  static IconData _iconData(String? name) {
    const iconMap = <String, IconData>{
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'local_hospital': Icons.local_hospital,
      'movie': Icons.movie,
      'receipt_long': Icons.receipt_long,
      'payments': Icons.payments,
      'help_outline': Icons.help_outline,
      'fitness_center': Icons.fitness_center,
      'school': Icons.school,
      'home': Icons.home,
      'pets': Icons.pets,
    };
    return iconMap[name] ?? Icons.category;
  }
}
