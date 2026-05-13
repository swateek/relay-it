import 'package:flutter/material.dart';

import '../../../core/theme/relayit_theme.dart';
import '../../../core/widgets/wordmark.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: RelayitColors.accentLight,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.bolt,
                color: RelayitColors.accent,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(child: Wordmark(fontSize: 28)),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Version 1.0.0 · build 1',
              style: RelayitTextStyles.caption(color: txt2),
            ),
          ),
          const SizedBox(height: 24),
          _InfoCard(
            children: const [
              _InfoRow(label: 'Developer', value: 'TBD'),
              _InfoRow(label: 'Platform', value: 'Android'),
              _InfoRow(label: 'Min. Android', value: '8.0 (API 26)'),
              _InfoRow(label: 'License', value: 'TBD'),
              _InfoRow(label: 'Contact', value: 'TBD'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Changelog'.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          _InfoCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1.0.0',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Initial release with SMS forwarding to WhatsApp, Email, and SMS destinations.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '• Persistent foreground listener and per-message logs.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Made with care in India',
              style: RelayitTextStyles.caption(color: txt2),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;
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
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const Divider(height: 0),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(value, style: RelayitTextStyles.caption(color: txt2)),
        ],
      ),
    );
  }
}
