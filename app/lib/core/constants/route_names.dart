class RouteNames {
  RouteNames._();

  static const String jobs = 'jobs';
  static const String createJob = 'create-job';
  static const String logs = 'logs';
  static const String logDetail = 'log-detail';
  static const String settings = 'settings';
  static const String about = 'about';
}

class RoutePaths {
  RoutePaths._();

  static const String jobs = '/jobs';
  static const String createJob = '/jobs/create';
  static const String logs = '/logs';
  static const String logDetail = '/logs/:id';
  static const String settings = '/settings';
  static const String about = '/settings/about';
}
