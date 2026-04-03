import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/category_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/category.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(categoryListProvider),
        ),
        data: (cats) {
          if (cats.isEmpty) {
            return const EmptyState(
              title: 'No categories yet',
              subtitle: 'Tap + to add a category',
              icon: Icons.category_outlined,
            );
          }
          return ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final cat = cats[index];
              return _CategoryTile(
                category: cat,
                onEdit: () => context.pushNamed(
                  'edit-category',
                  pathParameters: {'id': cat.id.toString()},
                  extra: cat,
                ),
                onDelete: cat.isSystem
                    ? null
                    : () => _confirmDelete(context, ref, cat),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('add-category'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Category cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
            '"${cat.name}" will be permanently removed. Transactions will keep their original category reference.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(deleteCategoryProvider).call(cat.id);
      ref.invalidate(categoryListProvider);
    }
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colour = _parseHex(category.colour);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colour.withAlpha(30),
        child: Icon(
          _iconData(category.icon),
          color: colour,
          size: 20,
        ),
      ),
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category.isSystem)
            const Chip(
              label: Text('System'),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: onDelete == null ? Theme.of(context).disabledColor : null,
            ),
            onPressed: onDelete,
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
