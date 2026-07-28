import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../storage/storage_service.dart';
import '../../features/calibration/presentation/pages/calibration_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static GoRouter get router {
    final bool onboardingDone = StorageService.getBool('onboarding_completed');

    return GoRouter(
      initialLocation: onboardingDone ? '/' : '/onboarding',
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (BuildContext context, GoRouterState state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (BuildContext context, GoRouterState state) => const OnboardingPage(),
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
}
