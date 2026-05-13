import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/settings/providers/settings_provider.dart';
import '../../services/sms_listener_service.dart';
import '../constants/strings.dart';

/// Drives the first-launch permission walkthrough described in the spec:
///   in-app rationale -> RECEIVE_SMS -> READ_CONTACTS -> POST_NOTIFICATIONS.
/// On permanent denial, offers to open app settings.
///
/// Once the flow has finished (or been skipped), the [SettingsState]
/// permissionsRequested flag is flipped so we never run it again.
class PermissionFlow {
  PermissionFlow._();

  static Future<void> maybeRunOnFirstLaunch(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final settings = ref.read(settingsNotifierProvider);
    if (settings.permissionsRequested) return;

    final start = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.permissionRationaleTitle),
        content: const Text(AppStrings.permissionRationaleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (start != true) {
      await ref
          .read(settingsNotifierProvider.notifier)
          .markPermissionsRequested();
      return;
    }

    await _request(
      context: context,
      permission: Permission.sms,
      rationale: AppStrings.permissionSmsRationale,
    );
    if (!context.mounted) return;

    await _request(
      context: context,
      permission: Permission.contacts,
      rationale: AppStrings.permissionContactsRationale,
      skippable: true,
    );
    if (!context.mounted) return;

    await _request(
      context: context,
      permission: Permission.notification,
      rationale: AppStrings.permissionNotificationsRationale,
    );
    if (!context.mounted) return;

    await ref
        .read(settingsNotifierProvider.notifier)
        .markPermissionsRequested();

    if (await Permission.sms.isGranted) {
      try {
        await SmsListenerService.start();
      } catch (_) {
        /* swallow — surfaced via settings */
      }
    }
  }

  static Future<void> _request({
    required BuildContext context,
    required Permission permission,
    required String rationale,
    bool skippable = false,
  }) async {
    var current = await permission.status;
    if (current.isGranted) return;

    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Text(rationale),
        actions: [
          if (skippable)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Skip'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed != true) return;
    if (!context.mounted) return;

    current = await permission.request();
    if (current.isPermanentlyDenied) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(AppStrings.permissionPermanentlyDeniedTitle),
          content: const Text(AppStrings.permissionPermanentlyDeniedBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not now'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
    }
  }
}
