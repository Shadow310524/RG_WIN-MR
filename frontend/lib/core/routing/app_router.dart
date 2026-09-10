import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgwin_crm/core/routing/responsive_scaffold.dart';
import 'package:rgwin_crm/core/routing/route_paths.dart';
import 'package:rgwin_crm/features/analytics/presentation/analytics_screen.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_state.dart';
import 'package:rgwin_crm/features/auth/presentation/login_screen.dart';
import 'package:rgwin_crm/features/dashboard/presentation/dashboard_shell_screen.dart';
import 'package:rgwin_crm/features/doctors/presentation/add_edit_doctor_screen.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_detail_screen.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctors_shell_screen.dart';
import 'package:rgwin_crm/features/expenses/presentation/record_expense_screen.dart';
import 'package:rgwin_crm/features/followups/presentation/followups_shell_screen.dart';
import 'package:rgwin_crm/features/more/presentation/more_shell_screen.dart';
import 'package:rgwin_crm/features/products/presentation/products_shell_screen.dart';
import 'package:rgwin_crm/features/sales/presentation/record_purchase_screen.dart';
import 'package:rgwin_crm/features/sales/presentation/sales_shell_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/record_visit_screen.dart';
import 'package:rgwin_crm/features/visits/presentation/visits_shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final List<NavigationItem> kAppNavigationItems = [
  const NavigationItem(
    label: "Home",
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    path: RoutePaths.dashboard,
  ),
  const NavigationItem(
    label: "Doctors",
    icon: Icons.people_outline_rounded,
    selectedIcon: Icons.people_rounded,
    path: RoutePaths.doctors,
  ),
  const NavigationItem(
    label: "Visits",
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment_rounded,
    path: RoutePaths.visits,
  ),
  const NavigationItem(
    label: "Sales",
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet_rounded,
    path: RoutePaths.sales,
  ),
  const NavigationItem(
    label: "More",
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
    path: RoutePaths.more,
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
      // Standalone modal / action routes
      GoRoute(
        path: RoutePaths.recordVisit,
        builder: (context, state) {
          final docId = state.uri.queryParameters['doctor_id'];
          return RecordVisitScreen(preselectedDoctorId: docId);
        },
      ),
      GoRoute(
        path: RoutePaths.recordPurchase,
        builder: (context, state) {
          final docId = state.uri.queryParameters['doctor_id'];
          return RecordPurchaseScreen(preselectedDoctorId: docId);
        },
      ),
      GoRoute(
        path: RoutePaths.recordExpense,
        builder: (context, state) => const RecordExpenseScreen(),
      ),
      GoRoute(
        path: RoutePaths.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: RoutePaths.products,
        builder: (context, state) => const ProductsShellScreen(),
      ),
      GoRoute(
        path: RoutePaths.followups,
        builder: (context, state) => const FollowupsShellScreen(),
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
          // Branch 0: Dashboard (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardShellScreen(),
              ),
            ],
          ),
          // Branch 1: Doctors Directory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.doctors,
                builder: (context, state) => const DoctorsShellScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddEditDoctorScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return DoctorDetailScreen(doctorId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return AddEditDoctorScreen(doctorId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Visits
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.visits,
                builder: (context, state) => const VisitsShellScreen(),
              ),
            ],
          ),
          // Branch 3: Sales
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.sales,
                builder: (context, state) => const SalesShellScreen(),
              ),
            ],
          ),
          // Branch 4: More
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.more,
                builder: (context, state) => const MoreShellScreen(),
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
