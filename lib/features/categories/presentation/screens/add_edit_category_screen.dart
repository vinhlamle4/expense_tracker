import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/category_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_input.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  const AddEditCategoryScreen({super.key, this.existing});

  final Category? existing;

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState
    extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colourController = TextEditingController();

  String _selectedIcon = 'category';
  bool _submitting = false;

  bool get _isEditMode => widget.existing != null;

  static const _availableIcons = [
    'restaurant',
    'directions_bus',
    'shopping_bag',
    'local_hospital',
    'movie',
    'receipt',
    'attach_money',
    'more_horiz',
    'category',
  ];

  static const _iconMap = <String, IconData>{
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

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final cat = widget.existing!;
      _nameController.text = cat.name;
      _colourController.text = cat.colour;
      _selectedIcon = cat.icon;
    } else {
      _colourController.text = '#1976D2';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = _parseHex(_colourController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Category' : 'Add Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length > 50) {
                  return 'Name cannot exceed 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Colour picker
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _colourController,
                    decoration: const InputDecoration(
                      labelText: 'Colour (hex, e.g. #1976D2)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Colour is required';
                      }
                      try {
                        _parseHex(v.trim());
                      } catch (_) {
                        return 'Enter a valid hex colour';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: previewColor,
                  radius: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Icon picker
            Text('Icon', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((name) {
                final isSelected = _selectedIcon == name;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = name),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      _iconMap[name] ?? Icons.circle,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditMode ? 'Save Changes' : 'Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    final h = hex.trim().replaceAll('#', '');
    final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
    return Color(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final input = CategoryInput(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        colour: _colourController.text.trim(),
      );

      if (_isEditMode) {
        await ref
            .read(updateCategoryProvider)
            .call(widget.existing!.id, input);
      } else {
        await ref.read(createCategoryProvider).call(input);
      }

      ref.invalidate(categoryListProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
