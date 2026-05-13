import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/theme/relayit_theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SectionHeader(text: 'Appearance'),
          _SettingsCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Match the system or pick a fixed mode.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<DarkModePreference>(
                    segments: [
                      for (final p in DarkModePreference.values)
                        ButtonSegment(value: p, label: Text(p.label)),
                    ],
                    selected: {settings.darkMode},
                    onSelectionChanged: (s) => notifier.setDarkMode(s.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionHeader(text: 'Behaviour'),
          _SettingsCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  title: const Text('Delivery notifications'),
                  subtitle: const Text('Show a toast when a forward succeeds.'),
                  value: settings.deliveryNotifications,
                  onChanged: notifier.setDeliveryNotifications,
                ),
                const Divider(height: 0),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  title: const Text('Auto-copy OTPs'),
                  subtitle: const Text(
                    'Copy detected one-time codes to the clipboard.',
                  ),
                  value: settings.autoCopyOtp,
                  onChanged: notifier.setAutoCopyOtp,
                ),
                const Divider(height: 0),
                _ChevronTile(
                  title: 'Log retention',
                  trailing: '${settings.logRetentionDays} days',
                  onTap: () async {
                    final picked = await showModalBottomSheet<int>(
                      context: context,
                      builder: (ctx) =>
                          _RetentionSheet(current: settings.logRetentionDays),
                    );
                    if (picked != null) {
                      await notifier.setLogRetentionDays(picked);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionHeader(text: 'Support & legal'),
          _SettingsCard(
            child: Column(
              children: [
                _ChevronTile(
                  title: 'Permissions',
                  onTap: () async {
                    await openAppSettings();
                  },
                ),
                const Divider(height: 0),
                _ChevronTile(title: 'Privacy policy', onTap: () {}),
                const Divider(height: 0),
                _ChevronTile(
                  title: 'About',
                  onTap: () => context.pushNamed(RouteNames.about),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 18, 6, 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? RelayitColors.borderSubtle
              : RelayitColors.darkBorder,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

class _ChevronTile extends StatelessWidget {
  const _ChevronTile({required this.title, required this.onTap, this.trailing});

  final String title;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[
            Text(trailing!, style: RelayitTextStyles.caption(color: txt2)),
            const SizedBox(width: 6),
          ],
          Icon(Icons.chevron_right, color: txt2),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _RetentionSheet extends StatelessWidget {
  const _RetentionSheet({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    const options = [7, 14, 30, 90];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log retention',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final opt in options)
              ListTile(
                title: Text('$opt days'),
                trailing: opt == current
                    ? const Icon(Icons.check, color: RelayitColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop(opt),
              ),
          ],
        ),
      ),
    );
  }
}
