import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/relayit_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../services/forwarder_service.dart';
import '../../../services/storage_service.dart';
import '../../jobs/models/destination.dart';
import '../models/delivery_receipt.dart';
import '../models/log_entry.dart';
import '../providers/logs_provider.dart';

class LogDetailScreen extends ConsumerWidget {
  const LogDetailScreen({super.key, required this.logId});

  final String logId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(logByIdProvider(logId));
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return Scaffold(
      appBar: AppBar(title: const Text('Log detail')),
      body: logAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Log no longer available.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _MetaBlock(entry: entry),
              const SizedBox(height: 16),
              _MessageBubble(body: entry.messageBody),
              const SizedBox(height: 24),
              Text(
                'Deliveries'.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              for (final d in entry.deliveries) ...[
                _DeliveryTile(receipt: d),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final job = await StorageService.getJob(entry.jobId);
                    if (job == null) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Job no longer exists.')),
                      );
                      return;
                    }
                    await ForwarderService.forward(
                      job: job,
                      sender: entry.sender,
                      body: entry.messageBody,
                    );
                    ref.invalidate(logsNotifierProvider);
                    ref.invalidate(logByIdProvider(logId));
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.reForwardSuccess),
                      ),
                    );
                  } catch (_) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text(AppStrings.reForwardError)),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: RelayitColors.accent,
                  side: const BorderSide(
                    color: RelayitColors.accentBorder,
                    width: 1,
                  ),
                ),
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: RelayitColors.accent,
                ),
                label: Text(
                  'Re-forward this message',
                  style: RelayitTextStyles.bodyMedium(
                    color: RelayitColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sender: ${entry.sender}',
                style: RelayitTextStyles.caption(color: txt2),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.entry});
  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt1 = isLight ? RelayitColors.textPrimary : RelayitColors.darkText1;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    final ok = entry.allDelivered;
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.jobName, style: RelayitTextStyles.bodyMedium(color: txt1)),
          const SizedBox(height: 4),
          Text(
            'From ${entry.sender} · ${DateFormatter.relativeAndTime(entry.receivedAt)}',
            style: RelayitTextStyles.caption(color: txt2),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle : Icons.error_outline,
                size: 16,
                color: ok ? RelayitColors.success : RelayitColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                ok
                    ? 'All ${entry.deliveries.length} destinations delivered'
                    : '${entry.successCount} of ${entry.deliveries.length} delivered',
                style: RelayitTextStyles.caption(color: txt2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RelayitColors.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelayitColors.accentBorder, width: 0.5),
      ),
      child: Text(
        body,
        style: RelayitTextStyles.body(color: RelayitColors.accentDark),
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({required this.receipt});
  final DeliveryReceipt receipt;

  IconData _channelIcon(DestinationType t) => switch (t) {
    DestinationType.whatsapp => Icons.chat_bubble_outline,
    DestinationType.email => Icons.mail_outline,
    DestinationType.sms => Icons.sms_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt1 = isLight ? RelayitColors.textPrimary : RelayitColors.darkText1;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    final ok = receipt.status == DeliveryStatus.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLight
              ? RelayitColors.borderSubtle
              : RelayitColors.darkBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: ok ? RelayitColors.success : RelayitColors.error,
          ),
          const SizedBox(width: 10),
          Icon(_channelIcon(receipt.type), size: 16, color: txt2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.label.isEmpty ? receipt.value : receipt.label,
                  style: RelayitTextStyles.bodyMedium(color: txt1),
                ),
                const SizedBox(height: 2),
                Text(
                  receipt.value,
                  style: RelayitTextStyles.caption(color: txt2),
                ),
                if (receipt.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    receipt.errorMessage!,
                    style: RelayitTextStyles.caption(
                      color: RelayitColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            DateFormatter.time(receipt.sentAt),
            style: RelayitTextStyles.caption(color: txt2),
          ),
        ],
      ),
    );
  }
}
