import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/calibration/presentation/pages/calibration_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (BuildContext context, GoRouterState state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/calibration',
        name: 'calibration',
        builder: (BuildContext context, GoRouterState state) => const CalibrationPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
      ),
    ],
  );
}
