import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgwin_crm/core/routing/responsive_scaffold.dart';
import 'package:rgwin_crm/core/routing/route_paths.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_state.dart';
import 'package:rgwin_crm/features/auth/presentation/login_screen.dart';
import 'package:rgwin_crm/features/dashboard/presentation/dashboard_shell_screen.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctors_shell_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/visits_shell_screen.dart';
import 'package:rgwin_crm/features/products/presentation/products_shell_screen.dart';
import 'package:rgwin_crm/features/followups/presentation/followups_shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final List<NavigationItem> kAppNavigationItems = [
  const NavigationItem(
    label: "Dashboard",
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    path: RoutePaths.dashboard,
  ),
  const NavigationItem(
    label: "Doctors",
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    path: RoutePaths.doctors,
  ),
  const NavigationItem(
    label: "Visits",
    icon: Icons.location_on_outlined,
    selectedIcon: Icons.location_on,
    path: RoutePaths.visits,
  ),
  const NavigationItem(
    label: "Products",
    icon: Icons.medication_outlined,
    selectedIcon: Icons.medication,
    path: RoutePaths.products,
  ),
  const NavigationItem(
    label: "Follow-ups",
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today,
    path: RoutePaths.followups,
  ),
];

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, current) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);

    // During initial session restoration check, do not perform unauthenticated redirect yet
    if (authState.status == AuthStatus.checking) {
      return null;
    }

    final isAuthenticated = authState.isAuthenticated;
    final isLoggingIn = state.matchedLocation == RoutePaths.login;

    // Unauthenticated user trying to access protected shell -> redirect to /login
    if (!isAuthenticated && !isLoggingIn) {
      return RoutePaths.login;
    }

    // Authenticated user trying to access /login -> redirect to /
    if (isAuthenticated && isLoggingIn) {
      return RoutePaths.dashboard;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

GoRouter createAppRouter({
  Listenable? refreshListenable,
  String? Function(BuildContext, GoRouterState)? redirect,
  String initialLocation = RoutePaths.dashboard,
}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: redirect,
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveScaffold(
            currentIndex: navigationShell.currentIndex,
            onNavigationIndexChanged: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            items: kAppNavigationItems,
            body: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.doctors,
                builder: (context, state) => const DoctorsShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.visits,
                builder: (context, state) => const VisitsShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.products,
                builder: (context, state) => const ProductsShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.followups,
                builder: (context, state) => const FollowupsShellScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  return createAppRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
  );
});

final GoRouter appRouter = createAppRouter();
