import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/csv_export_service.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/providers/category_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_providers.dart';
import '../../../shared/providers/transaction_providers.dart';
import '../../../shared/widgets/confirm_dialog_widget.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider);
    final themeAsync = ref.watch(themeVMProvider);
    final themeMode = themeAsync.valueOrNull ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Theme ────────────────────────────────────────────────────
          Text('Appearance', style: tt.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode)),
              ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode)),
            ],
            selected: {themeMode},
            onSelectionChanged: (s) {
              final modeStr = switch (s.first) {
                ThemeMode.light => 'light',
                ThemeMode.dark => 'dark',
                _ => 'system',
              };
              ref.read(themeVMProvider.notifier).setThemeMode(modeStr);
            },
          ),
          const SizedBox(height: 24),

          // ── Categories ───────────────────────────────────────────────
          Row(children: [
            Expanded(child: Text('Categories', style: tt.titleMedium)),
            FilledButton.tonal(
              onPressed: () => _showAddCategoryDialog(context, ref),
              child: const Text('Add'),
            ),
          ]),
          const SizedBox(height: 8),
          categoriesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (cats) {
              final custom = cats.where((c) => !c.isDefault).toList();
              if (custom.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No custom categories yet.',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                );
              }
              return Column(
                children: custom.map((cat) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(cat.colorValue).withAlpha(40),
                      child: Icon(
                        IconData(
                          int.parse(cat.icon, radix: 16),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(cat.colorValue),
                        size: 20,
                      ),
                    ),
                    title: Text(cat.name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: cs.error),
                      tooltip: 'Delete category',
                      onPressed: () async {
                        final confirmed = await ConfirmDialogWidget.show(
                          context,
                          title: 'Delete "${cat.name}"?',
                          content:
                              'All transactions in this category will be moved to Uncategorized.',
                          confirmLabel: 'Delete',
                          isDestructive: true,
                        );
                        if (confirmed) {
                          final catRepo =
                              ref.read(categoryRepoProvider);
                          final txRepo =
                              ref.read(transactionRepoProvider);
                          await catRepo.deleteAndReassign(cat.id, txRepo);
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // ── Export ───────────────────────────────────────────────────
          Text('Data', style: tt.titleMedium),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export to CSV'),
            onPressed: () => _exportCsv(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    // Request storage permission on Android.
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }
    }

    final txState = ref.read(transactionVMProvider).valueOrNull;
    final cats = ref.read(categoryListProvider).valueOrNull ?? [];
    if (txState == null) return;

    try {
      final file = await CsvExportService.exportToCsv(
        transactions: txState.filtered,
        categories: cats,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported: ${file.path}'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on ExportException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.message}')),
        );
      }
    }
  }

  Future<void> _showAddCategoryDialog(
      BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Category name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Add')),
        ],
      ),
    );
    if (confirmed == true && nameCtrl.text.trim().isNotEmpty) {
      final catRepo = ref.read(categoryRepoProvider);
      final id = nameCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
      final model = CategoryModelFactory.custom(
        id: 'custom_$id',
        name: nameCtrl.text.trim(),
      );
      await catRepo.add(model);
    }
  }
}
