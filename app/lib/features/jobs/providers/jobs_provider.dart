import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage_service.dart';
import '../models/destination.dart';
import '../models/job.dart';

class JobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async => StorageService.getAllJobs();

  Future<void> _refresh() async {
    state = AsyncData(await StorageService.getAllJobs());
  }

  Future<void> add(Job job) async {
    await StorageService.saveJob(job);
    await _refresh();
  }

  Future<void> updateJob(Job job) async {
    await StorageService.saveJob(job);
    await _refresh();
  }

  Future<void> delete(String id) async {
    await StorageService.deleteJob(id);
    await _refresh();
  }

  Future<void> toggle(String id, bool isActive) async {
    await StorageService.toggleJob(id, isActive);
    await _refresh();
  }

  Future<void> reload() => _refresh();
}

final jobsNotifierProvider = AsyncNotifierProvider<JobsNotifier, List<Job>>(
  JobsNotifier.new,
);

final activeJobsProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsNotifierProvider).value ?? const <Job>[];
  return jobs.where((j) => j.isActive).toList(growable: false);
});

// Re-export commonly used model types for screens that watch only this provider.
typedef JobsList = List<Job>;
typedef DestinationsList = List<Destination>;
