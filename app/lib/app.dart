import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/route_names.dart';
import 'core/theme/relayit_theme.dart';
import 'features/jobs/screens/create_job_screen.dart';
import 'features/jobs/screens/jobs_screen.dart';
import 'features/logs/screens/log_detail_screen.dart';
import 'features/logs/screens/logs_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/screens/about_screen.dart';
import 'features/settings/screens/settings_screen.dart';

class RelayitApp extends ConsumerWidget {
  const RelayitApp({super.key, this.scaffoldMessengerKey});

  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Relayit',
      debugShowCheckedModeBanner: false,
      theme: RelayitTheme.light(),
      darkTheme: RelayitTheme.dark(),
      themeMode: themeMode,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: _router,
    );
  }
}

final _rootKey = GlobalKey<NavigatorState>();
final _shellKeyJobs = GlobalKey<NavigatorState>();
final _shellKeyLogs = GlobalKey<NavigatorState>();
final _shellKeySettings = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: RoutePaths.jobs,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellKeyJobs,
          routes: [
            GoRoute(
              path: RoutePaths.jobs,
              name: RouteNames.jobs,
              builder: (context, state) => const JobsScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: RouteNames.createJob,
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) => const CreateJobScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellKeyLogs,
          routes: [
            GoRoute(
              path: RoutePaths.logs,
              name: RouteNames.logs,
              builder: (context, state) => const LogsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: RouteNames.logDetail,
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) =>
                      LogDetailScreen(logId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellKeySettings,
          routes: [
            GoRoute(
              path: RoutePaths.settings,
              name: RouteNames.settings,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'about',
                  name: RouteNames.about,
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
