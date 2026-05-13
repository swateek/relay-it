import 'package:flutter/material.dart';

import '../../../core/theme/relayit_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/log_entry.dart';

class LogRow extends StatelessWidget {
  const LogRow({super.key, required this.entry, required this.onTap});

  final LogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt1 = isLight ? RelayitColors.textPrimary : RelayitColors.darkText1;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    final dotColor = entry.allDelivered
        ? RelayitColors.success
        : RelayitColors.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.jobName,
                            style: RelayitTextStyles.bodyMedium(color: txt1),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormatter.time(entry.receivedAt),
                          style: RelayitTextStyles.caption(color: txt2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.messageBody,
                      style: RelayitTextStyles.caption(color: txt2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.successCount}/${entry.deliveries.length} delivered · from ${entry.sender}',
                      style: RelayitTextStyles.label(
                        color: isLight
                            ? RelayitColors.textHint
                            : RelayitColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
