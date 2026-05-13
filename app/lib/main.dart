import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/otp_extractor.dart';
import 'features/logs/providers/logs_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'services/sms_listener_service.dart';
import 'services/storage_service.dart';

/// Global key used by toasts that originate outside the widget tree
/// (e.g. when an SMS forward completes in the foreground-task isolate).
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

late final ProviderContainer rootContainer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();

  final prefs = await SharedPreferences.getInstance();
  final initialSettings = SettingsState.fromPrefs(prefs);

  await StorageService.purgeOlderThan(
    Duration(days: initialSettings.logRetentionDays),
  );

  FlutterForegroundTask.initCommunicationPort();
  SmsListenerService.initForegroundTask();

  rootContainer = ProviderContainer(
    overrides: [settingsBootstrapOverride(initialSettings)],
  );

  FlutterForegroundTask.addTaskDataCallback(_onTaskData);

  runApp(
    UncontrolledProviderScope(
      container: rootContainer,
      child: RelayitApp(scaffoldMessengerKey: scaffoldMessengerKey),
    ),
  );
}

void _onTaskData(Object data) {
  if (data is! Map) return;
  if (data['event'] != kIncomingForwardedEvent) return;

  rootContainer.read(logsNotifierProvider.notifier).refresh();

  final settings = rootContainer.read(settingsNotifierProvider);
  final body = data['body'] as String? ?? '';
  final jobName = data['jobName'] as String?;
  final success = (data['success'] as num?)?.toInt() ?? 0;
  final total = (data['total'] as num?)?.toInt() ?? 0;

  if (settings.autoCopyOtp) {
    final otp = OtpExtractor.extract(body);
    if (otp != null) {
      Clipboard.setData(ClipboardData(text: otp));
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('OTP $otp copied to clipboard')),
      );
    }
  }

  if (settings.deliveryNotifications && jobName != null && total > 0) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Forwarded "$jobName" · $success/$total delivered'),
      ),
    );
  }
}
