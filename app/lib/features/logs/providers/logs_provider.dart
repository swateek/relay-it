import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage_service.dart';
import '../models/log_entry.dart';

class LogsNotifier extends AsyncNotifier<List<LogEntry>> {
  @override
  Future<List<LogEntry>> build() async => StorageService.getLogs();

  Future<void> refresh() async {
    state = AsyncData(await StorageService.getLogs());
  }
}

final logsNotifierProvider =
    AsyncNotifierProvider<LogsNotifier, List<LogEntry>>(LogsNotifier.new);

final logByIdProvider = FutureProvider.family<LogEntry?, String>(
  (ref, id) async => StorageService.getLog(id),
);
