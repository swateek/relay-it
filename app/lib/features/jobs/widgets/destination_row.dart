import 'package:flutter/material.dart';

import '../../../core/theme/relayit_theme.dart';
import '../models/destination.dart';

class DestinationRow extends StatelessWidget {
  const DestinationRow({
    super.key,
    required this.destination,
    required this.onDelete,
  });

  final Destination destination;
  final VoidCallback onDelete;

  IconData _iconFor(DestinationType t) => switch (t) {
    DestinationType.whatsapp => Icons.chat_bubble_outline,
    DestinationType.email => Icons.mail_outline,
    DestinationType.sms => Icons.sms_outlined,
  };

  String _labelFor(DestinationType t) => switch (t) {
    DestinationType.whatsapp => 'WhatsApp',
    DestinationType.email => 'Email',
    DestinationType.sms => 'SMS',
  };

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt1 = isLight ? RelayitColors.textPrimary : RelayitColors.darkText1;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    final border = isLight
        ? RelayitColors.borderSubtle
        : RelayitColors.darkBorder;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(_iconFor(destination.type), size: 18, color: txt2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.label.isEmpty
                      ? _labelFor(destination.type)
                      : '${destination.label} · ${_labelFor(destination.type)}',
                  style: RelayitTextStyles.bodyMedium(color: txt1),
                ),
                const SizedBox(height: 2),
                Text(
                  destination.value,
                  style: RelayitTextStyles.caption(color: txt2),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
