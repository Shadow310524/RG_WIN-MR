import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/widgets/app_badge.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

class ResponsiveScaffold extends ConsumerWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onNavigationIndexChanged;
  final List<NavigationItem> items;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavigationIndexChanged,
    required this.items,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  static const double kTabletBreakpoint = 768.0;
  static const double kDesktopBreakpoint = 1024.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final defaultActions = <Widget>[
      if (authState.user != null) ...[
        Center(
          child: AppBadge(
            label: authState.user!.role.toUpperCase(),
            variant: authState.user!.role.toUpperCase() == 'ADMIN'
                ? AppBadgeVariant.active
                : AppBadgeVariant.info,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20),
          tooltip: 'Sign Out (${authState.user!.fullName})',
          onPressed: () => ref.read(authProvider.notifier).logout(),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    ];

    final effectiveActions = actions ?? defaultActions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= kTabletBreakpoint;

        if (isDesktop) {
          // Tablet & Desktop: NavigationRail sidebar + content
          return Scaffold(
            appBar: AppBar(
              title: Text(title ?? items[currentIndex].label),
              actions: effectiveActions,
              leading: null,
              automaticallyImplyLeading: false,
            ),
            floatingActionButton: floatingActionButton,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onNavigationIndexChanged,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Center(
                            child: Text(
                              "RG",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          "HEALIX",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryDark,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  destinations: items.map((item) {
                    return NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
                Expanded(
                  child: Container(color: AppColors.background, child: body),
                ),
              ],
            ),
          );
        }

        // Mobile: Standard AppBar + Body + BottomNavigationBar
        return Scaffold(
          appBar: AppBar(
            title: Text(title ?? items[currentIndex].label),
            actions: effectiveActions,
          ),
          body: Container(color: AppColors.background, child: body),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onNavigationIndexChanged,
            destinations: items.map((item) {
              return NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
