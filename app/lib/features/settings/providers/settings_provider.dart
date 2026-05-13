import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

enum DarkModePreference { system, light, dark }

extension DarkModePreferenceX on DarkModePreference {
  String get storageValue => switch (this) {
    DarkModePreference.system => 'system',
    DarkModePreference.light => 'light',
    DarkModePreference.dark => 'dark',
  };

  ThemeMode get themeMode => switch (this) {
    DarkModePreference.system => ThemeMode.system,
    DarkModePreference.light => ThemeMode.light,
    DarkModePreference.dark => ThemeMode.dark,
  };

  String get label => switch (this) {
    DarkModePreference.system => 'System',
    DarkModePreference.light => 'Light',
    DarkModePreference.dark => 'Dark',
  };

  static DarkModePreference fromStorage(String? raw) {
    switch (raw) {
      case 'light':
        return DarkModePreference.light;
      case 'dark':
        return DarkModePreference.dark;
      default:
        return DarkModePreference.system;
    }
  }
}

class SettingsState {
  const SettingsState({
    required this.darkMode,
    required this.deliveryNotifications,
    required this.autoCopyOtp,
    required this.logRetentionDays,
    required this.permissionsRequested,
    required this.whatsappEmailDialogShown,
  });

  final DarkModePreference darkMode;
  final bool deliveryNotifications;
  final bool autoCopyOtp;
  final int logRetentionDays;

  /// True once the user has been walked through the first-run permission flow.
  final bool permissionsRequested;

  /// True once the one-time "WhatsApp/Email opens the app" dialog has been shown.
  final bool whatsappEmailDialogShown;

  SettingsState copyWith({
    DarkModePreference? darkMode,
    bool? deliveryNotifications,
    bool? autoCopyOtp,
    int? logRetentionDays,
    bool? permissionsRequested,
    bool? whatsappEmailDialogShown,
  }) => SettingsState(
    darkMode: darkMode ?? this.darkMode,
    deliveryNotifications: deliveryNotifications ?? this.deliveryNotifications,
    autoCopyOtp: autoCopyOtp ?? this.autoCopyOtp,
    logRetentionDays: logRetentionDays ?? this.logRetentionDays,
    permissionsRequested: permissionsRequested ?? this.permissionsRequested,
    whatsappEmailDialogShown:
        whatsappEmailDialogShown ?? this.whatsappEmailDialogShown,
  );

  static const _kDarkMode = 'dark_mode';
  static const _kDeliveryNotifications = 'delivery_notifications';
  static const _kAutoCopyOtp = 'auto_copy_otp';
  static const _kLogRetentionDays = 'log_retention_days';
  static const _kPermissionsRequested = 'permissions_requested_v1';
  static const _kWhatsappEmailDialogShown = 'wa_email_dialog_shown_v1';

  static const defaults = SettingsState(
    darkMode: DarkModePreference.system,
    deliveryNotifications: true,
    autoCopyOtp: true,
    logRetentionDays: 30,
    permissionsRequested: false,
    whatsappEmailDialogShown: false,
  );

  static SettingsState fromPrefs(SharedPreferences prefs) => SettingsState(
    darkMode: DarkModePreferenceX.fromStorage(prefs.getString(_kDarkMode)),
    deliveryNotifications:
        prefs.getBool(_kDeliveryNotifications) ??
        defaults.deliveryNotifications,
    autoCopyOtp: prefs.getBool(_kAutoCopyOtp) ?? defaults.autoCopyOtp,
    logRetentionDays:
        prefs.getInt(_kLogRetentionDays) ?? defaults.logRetentionDays,
    permissionsRequested:
        prefs.getBool(_kPermissionsRequested) ?? defaults.permissionsRequested,
    whatsappEmailDialogShown:
        prefs.getBool(_kWhatsappEmailDialogShown) ??
        defaults.whatsappEmailDialogShown,
  );
}

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    return ref.read(_settingsBootstrapProvider);
  }

  Future<void> _ensurePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setDarkMode(DarkModePreference pref) async {
    await _ensurePrefs();
    await _prefs.setString(SettingsState._kDarkMode, pref.storageValue);
    state = state.copyWith(darkMode: pref);
  }

  Future<void> setDeliveryNotifications(bool value) async {
    await _ensurePrefs();
    await _prefs.setBool(SettingsState._kDeliveryNotifications, value);
    state = state.copyWith(deliveryNotifications: value);
  }

  Future<void> setAutoCopyOtp(bool value) async {
    await _ensurePrefs();
    await _prefs.setBool(SettingsState._kAutoCopyOtp, value);
    state = state.copyWith(autoCopyOtp: value);
  }

  Future<void> setLogRetentionDays(int days) async {
    await _ensurePrefs();
    await _prefs.setInt(SettingsState._kLogRetentionDays, days);
    state = state.copyWith(logRetentionDays: days);
  }

  Future<void> markPermissionsRequested() async {
    await _ensurePrefs();
    await _prefs.setBool(SettingsState._kPermissionsRequested, true);
    state = state.copyWith(permissionsRequested: true);
  }

  Future<void> markWhatsappEmailDialogShown() async {
    await _ensurePrefs();
    await _prefs.setBool(SettingsState._kWhatsappEmailDialogShown, true);
    state = state.copyWith(whatsappEmailDialogShown: true);
  }
}

/// Holds a snapshot of [SharedPreferences] read once at boot so the
/// synchronous [Notifier] can return a complete initial state.
final _settingsBootstrapProvider = Provider<SettingsState>(
  (ref) => throw UnimplementedError(
    'settingsBootstrapProvider must be overridden in ProviderScope',
  ),
);

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

/// Convenience selector for the active [ThemeMode] driven by the user setting.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsNotifierProvider).darkMode.themeMode,
);

/// Helper to wire the bootstrap override at app startup.
Override settingsBootstrapOverride(SettingsState initial) =>
    _settingsBootstrapProvider.overrideWithValue(initial);
