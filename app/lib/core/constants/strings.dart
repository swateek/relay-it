class AppStrings {
  AppStrings._();

  static const String appName = 'Relayit';

  static const String foregroundNotificationTitle = 'Relayit';
  static const String foregroundNotificationBody =
      'Relayit is watching for messages.';
  static const String foregroundChannelId = 'relayit_foreground';
  static const String foregroundChannelName = 'Relayit background listener';
  static const String foregroundChannelDescription =
      'Keeps Relayit watching for incoming SMS while the app is closed.';

  static const String jobsEmptyTitle = 'No jobs yet';
  static const String jobsEmptyBody =
      'Create your first forwarding rule to begin relaying messages.';

  static const String logsEmptyTitle = 'No relayed messages yet';
  static const String logsEmptyBody =
      'Once an SMS matches a job, the delivery shows up here.';

  static const String permissionRationaleTitle =
      'Relayit needs a few permissions';
  static const String permissionRationaleBody =
      'Relayit reads incoming SMS, optionally accesses contacts to match a job source by name, and posts a quiet notification while the listener runs in the background. Nothing leaves your device.';

  static const String permissionSmsRationale =
      'Allow SMS access so Relayit can detect messages that match your jobs.';
  static const String permissionContactsRationale =
      'Allow contacts access if you plan to match jobs by contact name. You can skip this.';
  static const String permissionNotificationsRationale =
      'Allow notifications so Relayit can keep its persistent listener notification visible.';

  static const String permissionPermanentlyDeniedTitle = 'Permission required';
  static const String permissionPermanentlyDeniedBody =
      'This permission was permanently denied. Open settings to enable it manually.';

  static const String whatsappEmailDialogTitle = 'Heads up';
  static const String whatsappEmailDialogBody =
      'WhatsApp and Email destinations open the respective app to send the message; they are not silent in v1. This dialog will not appear again.';

  static const String reForwardSuccess = 'Forward triggered.';
  static const String reForwardError = 'Could not re-forward.';

  static const String filtersV1Disclaimer =
      'Filters are stored visually for now; they are not applied to incoming messages in v1.';
}
