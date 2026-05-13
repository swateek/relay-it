import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:telephony/telephony.dart';

import '../core/constants/strings.dart';
import '../features/jobs/models/job.dart';
import 'forwarder_service.dart';
import 'storage_service.dart';

bool _matches(Job job, String sender) =>
    sender.toLowerCase().contains(job.sourceValue.toLowerCase());

@pragma('vm:entry-point')
void relayitForegroundEntry() {
  FlutterForegroundTask.setTaskHandler(RelayitTaskHandler());
}

class RelayitTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await StorageService.init();
    } catch (e) {
      debugPrint('StorageService init in foreground isolate failed: $e');
    }
    Telephony.instance.listenIncomingSms(
      onNewMessage: _handleIncoming,
      listenInBackground: false,
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

const String kIncomingForwardedEvent = 'relayit.incoming.forwarded';

void _handleIncoming(SmsMessage message) {
  Future.microtask(() async {
    final sender = message.address ?? '';
    final body = message.body ?? '';
    if (sender.isEmpty) return;
    try {
      final jobs = await StorageService.getActiveJobs();
      var anyForwarded = false;
      for (final job in jobs) {
        if (_matches(job, sender)) {
          final entry = await ForwarderService.forward(
            job: job,
            sender: sender,
            body: body,
          );
          anyForwarded = true;
          FlutterForegroundTask.sendDataToMain(<String, Object?>{
            'event': kIncomingForwardedEvent,
            'sender': sender,
            'body': body,
            'jobName': job.name,
            'success': entry.successCount,
            'total': entry.deliveries.length,
          });
        }
      }
      if (!anyForwarded) {
        // Still surface the raw message so the UI isolate can auto-copy OTPs.
        FlutterForegroundTask.sendDataToMain(<String, Object?>{
          'event': kIncomingForwardedEvent,
          'sender': sender,
          'body': body,
          'jobName': null,
          'success': 0,
          'total': 0,
        });
      }
    } catch (e) {
      debugPrint('SMS handling failed: $e');
    }
  });
}

class SmsListenerService {
  SmsListenerService._();

  /// Initialize foreground task config. Must be called from the UI isolate
  /// before [start].
  static void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppStrings.foregroundChannelId,
        channelName: AppStrings.foregroundChannelName,
        channelDescription: AppStrings.foregroundChannelDescription,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
      ),
    );
  }

  /// Start the persistent foreground service. No-op if already running.
  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.startService(
      notificationTitle: AppStrings.foregroundNotificationTitle,
      notificationText: AppStrings.foregroundNotificationBody,
      callback: relayitForegroundEntry,
    );
  }

  static Future<void> stop() async {
    if (!await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.stopService();
  }

  static Future<bool> get isRunning => FlutterForegroundTask.isRunningService;
}
