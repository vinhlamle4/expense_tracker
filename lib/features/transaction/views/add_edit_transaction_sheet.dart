import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/transaction_model.dart';
import '../../../shared/providers/transaction_providers.dart';
import '../../../shared/widgets/category_picker_widget.dart';

/// Shows [AddEditTransactionSheet] as a modal bottom sheet.
Future<void> showAddEditTransactionSheet(
  BuildContext context, {
  TransactionModel? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddEditTransactionSheet(existing: existing),
  );
}

class AddEditTransactionSheet extends HookConsumerWidget {
  const AddEditTransactionSheet({super.key, this.existing});

  final TransactionModel? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    final isIncome = useState(existing?.isIncome ?? false);
    final selectedDate = useState(existing?.date ?? DateTime.now());
    final selectedCategoryId = useState<String?>(existing?.categoryId);
    final amountCtrl = useTextEditingController(
        text: existing != null ? existing!.amount.toStringAsFixed(0) : '');
    final noteCtrl =
        useTextEditingController(text: existing?.note ?? '');
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isSaving = useState(false);

    final isEdit = existing != null;

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      if (selectedCategoryId.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }
      isSaving.value = true;
      try {
        final amount = double.parse(amountCtrl.text.trim());
        final model = (existing ?? TransactionModel())
          ..amount = amount
          ..date = selectedDate.value
          ..isIncome = isIncome.value
          ..categoryId = selectedCategoryId.value!
          ..note = noteCtrl.text.trim();

        final vm = ref.read(transactionVMProvider.notifier);
        if (isEdit) {
          await vm.updateTransaction(model);
        } else {
          await vm.addTransaction(model);
        }
        if (context.mounted) Navigator.of(context).pop();
      } finally {
        isSaving.value = false;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(children: [
              Text(
                isEdit ? 'Edit Transaction' : 'Add Transaction',
                style: tt.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Income / Expense toggle ──────────────────────────────────
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: false,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward)),
                ButtonSegment(
                    value: true,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward)),
              ],
              selected: {isIncome.value},
              onSelectionChanged: (s) {
                isIncome.value = s.first;
                selectedCategoryId.value = null;
              },
            ),
            const SizedBox(height: 16),

            // ── Amount ───────────────────────────────────────────────────
            TextFormField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (VND)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Enter a positive amount';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Date ─────────────────────────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                  DateFormat('dd MMM yyyy').format(selectedDate.value)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) selectedDate.value = picked;
              },
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Category ─────────────────────────────────────────────────
            CategoryPickerWidget(
              isIncome: isIncome.value,
              selectedId: selectedCategoryId.value,
              onSelected: (cat) => selectedCategoryId.value = cat.id,
            ),
            const SizedBox(height: 12),

            // ── Note ─────────────────────────────────────────────────────
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // ── Save ─────────────────────────────────────────────────────
            FilledButton.icon(
              onPressed: isSaving.value ? null : save,
              icon: isSaving.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(isEdit ? 'Save Changes' : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

