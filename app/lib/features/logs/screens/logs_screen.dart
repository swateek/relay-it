import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/relayit_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/log_entry.dart';
import '../providers/logs_provider.dart';
import '../widgets/log_row.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(logsNotifierProvider.notifier).refresh(),
        child: logsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (logs) {
            if (logs.isEmpty) return const _EmptyLogs();
            final grouped = _groupByDate(logs);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: grouped.length,
              itemBuilder: (context, i) {
                final group = grouped[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      child: Text(
                        group.label,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    for (var j = 0; j < group.entries.length; j++) ...[
                      LogRow(
                        entry: group.entries[j],
                        onTap: () => context.pushNamed(
                          RouteNames.logDetail,
                          pathParameters: {'id': group.entries[j].id},
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<_LogGroup> _groupByDate(List<LogEntry> entries) {
    final map = <String, List<LogEntry>>{};
    for (final e in entries) {
      final key = DateFormatter.groupLabel(e.receivedAt);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map.entries
        .map((e) => _LogGroup(label: e.key, entries: e.value))
        .toList(growable: false);
  }
}

class _LogGroup {
  _LogGroup({required this.label, required this.entries});
  final String label;
  final List<LogEntry> entries;
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: RelayitColors.accentLight,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.receipt_long_outlined,
              color: RelayitColors.accent,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            AppStrings.logsEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppStrings.logsEmptyBody,
              style: RelayitTextStyles.caption(color: txt2),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
