import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection.dart';
import '../../features/analytics/presentation/cubit/analytics_cubit.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/widgets/neuro_bottom_nav.dart';
import '../../features/patients/presentation/cubit/patients_cubit.dart';
import '../../features/patients/presentation/pages/patients_page.dart';
import '../../features/patients/presentation/pages/patient_profile_page.dart';
import '../../features/sessions/presentation/pages/session_detail_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../constants/colors.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      // ── Shell route (4-tab scaffold) ────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ScaffoldWithNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => _fadePage(
                BlocProvider(
                  create: (_) => getIt<DashboardCubit>()..initDashboardStream(),
                  child: const DashboardPage(),
                ),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patients',
              pageBuilder: (context, state) => _fadePage(
                BlocProvider(
                  create: (_) => getIt<PatientsCubit>()..loadPatients(),
                  child: const PatientsPage(),
                ),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/analytics',
              pageBuilder: (context, state) => _fadePage(
                BlocProvider(
                  create: (_) => getIt<AnalyticsCubit>()..loadAnalytics(),
                  child: const AnalyticsPage(),
                ),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => _fadePage(const SettingsPage()),
            ),
          ]),
        ],
      ),

      // ── Full-screen routes (outside shell) ───────────────────────────
      GoRoute(
        path: '/sessions/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _slidePage(SessionDetailPage(sessionId: id));
        },
      ),
      GoRoute(
        path: '/patients/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _slidePage(PatientProfilePage(patientId: id));
        },
      ),
    ],
  );
}

// ── Scaffold with bottom nav ──────────────────────────────────────────────────
class _ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _ScaffoldWithNav({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: NeuroBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ── Page transition helpers ───────────────────────────────────────────────────

/// Cross-fade for tab switches.
CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Slide-left for forward navigation (session detail, patient profile).
CustomTransitionPage<void> _slidePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
              begin: const Offset(1.0, 0), end: Offset.zero)
          .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut));
      final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut));
      return FadeTransition(
        opacity: fadeOut,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
