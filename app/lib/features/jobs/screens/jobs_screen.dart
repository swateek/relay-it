import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/relayit_theme.dart';
import '../../../core/widgets/permission_flow.dart';
import '../../../core/widgets/wordmark.dart';
import '../providers/jobs_provider.dart';
import '../widgets/job_card.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  bool _flowKicked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_flowKicked || !mounted) return;
      _flowKicked = true;
      PermissionFlow.maybeRunOnFirstLaunch(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Wordmark(fontSize: 20),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goNamed(RouteNames.settings),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.createJob),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create job',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (jobs) {
          if (jobs.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: jobs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final job = jobs[i];
              return JobCard(
                job: job,
                onToggle: (v) =>
                    ref.read(jobsNotifierProvider.notifier).toggle(job.id, v),
                onTap: () {
                  // For v1, tapping a card simply re-opens it in create flow
                  // is out of scope; surface job details via long-press / edit
                  // when implemented. The plan focuses on listing + toggle.
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: RelayitColors.accentLight,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.swap_horiz,
                color: RelayitColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.jobsEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.jobsEmptyBody,
              style: RelayitTextStyles.caption(color: txt2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
