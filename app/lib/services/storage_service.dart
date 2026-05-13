import 'package:hive_flutter/hive_flutter.dart';

import '../features/jobs/models/destination.dart';
import '../features/jobs/models/job.dart';
import '../features/logs/models/delivery_receipt.dart';
import '../features/logs/models/log_entry.dart';

class StorageService {
  StorageService._();

  static const String jobsBoxName = 'jobs';
  static const String logsBoxName = 'logs';

  static bool _adaptersRegistered = false;

  /// Initialize Hive in whichever isolate calls this (UI isolate or the
  /// foreground task isolate). Safe to call multiple times.
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!_adaptersRegistered) {
      Hive.registerAdapter(JobAdapter());
      Hive.registerAdapter(DestinationAdapter());
      Hive.registerAdapter(LogEntryAdapter());
      Hive.registerAdapter(DeliveryReceiptAdapter());
      Hive.registerAdapter(SourceTypeAdapter());
      Hive.registerAdapter(DestinationTypeAdapter());
      Hive.registerAdapter(DeliveryStatusAdapter());
      _adaptersRegistered = true;
    }
    if (!Hive.isBoxOpen(jobsBoxName)) {
      await Hive.openBox<Job>(jobsBoxName);
    }
    if (!Hive.isBoxOpen(logsBoxName)) {
      await Hive.openBox<LogEntry>(logsBoxName);
    }
  }

  static Box<Job> get _jobs => Hive.box<Job>(jobsBoxName);
  static Box<LogEntry> get _logs => Hive.box<LogEntry>(logsBoxName);

  // ---------------- jobs ----------------

  static Future<List<Job>> getAllJobs() async =>
      _jobs.values.toList(growable: false);

  static Future<List<Job>> getActiveJobs() async =>
      _jobs.values.where((j) => j.isActive).toList(growable: false);

  static Future<Job?> getJob(String id) async => _jobs.get(id);

  static Future<void> saveJob(Job job) async => _jobs.put(job.id, job);

  static Future<void> deleteJob(String id) async => _jobs.delete(id);

  static Future<void> toggleJob(String id, bool isActive) async {
    final job = _jobs.get(id);
    if (job == null) return;
    await _jobs.put(id, job.copyWith(isActive: isActive));
  }

  /// Records a delivery against the job (updates lastFiredAt + deliveryCount).
  static Future<void> bumpDeliveryStats(
    String jobId, {
    required DateTime firedAt,
    required int delta,
  }) async {
    final job = _jobs.get(jobId);
    if (job == null) return;
    await _jobs.put(
      jobId,
      job.copyWith(
        lastFiredAt: firedAt,
        deliveryCount: job.deliveryCount + delta,
      ),
    );
  }

  // ---------------- logs ----------------

  static Future<List<LogEntry>> getLogs() async {
    final logs = _logs.values.toList(growable: false);
    logs.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return logs;
  }

  static Future<LogEntry?> getLog(String id) async => _logs.get(id);

  static Future<void> addLog(LogEntry entry) async =>
      _logs.put(entry.id, entry);

  static Future<int> purgeOlderThan(Duration retention) async {
    final cutoff = DateTime.now().subtract(retention);
    final stale = _logs.values
        .where((l) => l.receivedAt.isBefore(cutoff))
        .map((l) => l.id)
        .toList(growable: false);
    if (stale.isEmpty) return 0;
    await _logs.deleteAll(stale);
    return stale.length;
  }
}
