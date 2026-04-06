import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized service for permission checks, rationale dialogs, and denial
/// handling — per Constitution Principle VI (Security & Permissions).
///
/// All logic lives here in the Service layer; Widgets MUST NOT call
/// [Permission] directly.
abstract final class PermissionService {
  // ── Public API ─────────────────────────────────────────────────────────────

  /// Ensures the storage permission required to write CSV files to the public
  /// Downloads folder is granted.
  ///
  /// Flow (per Constitution Principle VI):
  ///   1. If already granted → return true immediately.
  ///   2. Show a rationale dialog explaining why the permission is needed.
  ///   3. If the user declines the rationale → return false.
  ///   4. Request the permission via [permission_handler].
  ///   5. If denied or permanently denied → show guidance dialog → return false.
  ///
  /// On **iOS** no runtime storage permission is required — the Documents
  /// directory is exposed via the Files app when `UIFileSharingEnabled = true`
  /// in Info.plist. Returns `true` immediately on iOS.
  static Future<bool> ensureStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final permission = Permission.manageExternalStorage;
    var status = await permission.status;
    if (status.isGranted) return true;

    // Step 2 — Always show rationale before the OS dialog (Constitution VI).
    if (!context.mounted) return false;
    final shouldRequest = await _showRationaleDialog(context);
    if (!shouldRequest) return false;

    // Step 4 — Request the permission.
    status = await permission.request();
    if (status.isGranted) return true;

    // Step 5 — Handle denial.
    if (context.mounted) {
      await _showDenialDialog(
        context,
        isPermanent: status.isPermanentlyDenied,
      );
    }
    return false;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Shows a rationale dialog explaining why storage access is needed.
  /// Returns [true] if the user agreed to proceed, [false] otherwise.
  static Future<bool> _showRationaleDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.folder_open_outlined),
            title: const Text('Storage Access Needed'),
            content: const Text(
              'Expense Tracker needs access to your device storage to save '
              'exported CSV files to the Downloads folder, where you can '
              'easily find, open, and share them.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Not Now'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Allow'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Shows a dialog informing the user that the permission was denied.
  /// For permanently denied permissions, offers an "Open Settings" button.
  static Future<void> _showDenialDialog(
    BuildContext context, {
    required bool isPermanent,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.block_outlined),
        title: const Text('Permission Denied'),
        content: Text(
          isPermanent
              ? 'Storage permission was permanently denied. Please open '
                  'Settings and enable "All Files Access" for Expense Tracker '
                  'to export CSV files.'
              : 'Storage permission is required to save CSV files to the '
                  'Downloads folder. Please allow it when prompted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          if (isPermanent)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                openAppSettings(); // Opens device Settings → app permission page.
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }
}
