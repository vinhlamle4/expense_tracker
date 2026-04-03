import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/transaction_providers.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_input.dart';
import '../providers/transaction_list_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({super.key, this.existing});

  /// If non-null, the form is in edit mode for this transaction.
  final Transaction? existing;

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  int? _categoryId;
  DateTime _date = DateTime.now();
  bool _submitting = false;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final t = widget.existing!;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note ?? '';
      _type = t.type;
      _categoryId = t.categoryId;
      _date = DateTime.parse(t.date);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₫)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final n = int.tryParse(v.trim());
                if (n == null) return 'Enter a valid number';
                if (n <= 0) return 'Amount must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type toggle
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),

            // Category
            categoriesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => const Text('Failed to load categories'),
              data: (cats) => DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: cats
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: _parseHex(c.colour)
                                    .withAlpha(30),
                                child: Icon(
                                  _catIcon(c.icon),
                                  size: 12,
                                  color: _parseHex(c.colour),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Please select a category' : null,
              ),
            ),
            const SizedBox(height: 16),

            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              ),
              subtitle: const Text('Transaction date'),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (v) {
                if (v != null && v.length > 500) {
                  return 'Note cannot exceed 500 characters';
                }
                return null;
              },
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
                  : Text(_isEditMode ? 'Save Changes' : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final input = TransactionInput(
        amount: int.parse(_amountController.text.trim()),
        type: _type,
        categoryId: _categoryId!,
        date:
            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (_isEditMode) {
        await ref.read(updateTransactionProvider).call(widget.existing!.id, input);
      } else {
        await ref.read(createTransactionProvider).call(input);
      }

      ref.invalidate(transactionListProvider);
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

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
      return Color(value);
    } catch (_) {
      return const Color(0xFF1976D2);
    }
  }

  IconData _catIcon(String name) {
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
