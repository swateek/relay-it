import 'package:flutter/material.dart';

import '../../../core/theme/relayit_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/destination.dart';
import '../models/job.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onToggle,
    required this.onTap,
  });

  final Job job;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt1 = isLight ? RelayitColors.textPrimary : RelayitColors.darkText1;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.name,
                      style: RelayitTextStyles.appBarTitle(
                        color: txt1,
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  Switch(value: job.isActive, onChanged: onToggle),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _sourceLabel(job),
                style: RelayitTextStyles.caption(color: txt2),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final d in job.destinations) _DestinationPill(d: d),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 14, color: txt2),
                  const SizedBox(width: 4),
                  Text(
                    job.lastFiredAt == null
                        ? 'Not fired yet'
                        : DateFormatter.relativeAndTime(job.lastFiredAt!),
                    style: RelayitTextStyles.caption(color: txt2),
                  ),
                  const Spacer(),
                  Icon(Icons.bolt_outlined, size: 14, color: txt2),
                  const SizedBox(width: 4),
                  Text(
                    '${job.deliveryCount} delivered',
                    style: RelayitTextStyles.caption(color: txt2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sourceLabel(Job j) {
    final prefix = switch (j.sourceType) {
      SourceType.senderId => 'Sender ID',
      SourceType.phoneNumber => 'Phone',
      SourceType.contactName => 'Contact',
    };
    return '$prefix · ${j.sourceValue}';
  }
}

class _DestinationPill extends StatelessWidget {
  const _DestinationPill({required this.d});
  final Destination d;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? RelayitColors.bgMuted : RelayitColors.darkBgMuted;
    final fg = isLight ? RelayitColors.sandFg : RelayitColors.darkText2;
    final icon = switch (d.type) {
      DestinationType.whatsapp => Icons.chat_bubble_outline,
      DestinationType.email => Icons.mail_outline,
      DestinationType.sms => Icons.sms_outlined,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isLight
              ? RelayitColors.borderSubtle
              : RelayitColors.darkBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            d.label.isEmpty ? d.value : d.label,
            style: RelayitTextStyles.caption(color: fg),
          ),
        ],
      ),
    );
  }
}
