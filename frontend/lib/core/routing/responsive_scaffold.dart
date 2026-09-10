import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
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

  static const double kMaxMobileWidth = 480.0;

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
        const SizedBox(width: AppSpacing.xs),
      ],
    ];

    final effectiveActions = actions ?? defaultActions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > kMaxMobileWidth;

        final scaffoldContent = Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Center(
                    child: Text(
                      "RG",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title ?? items[currentIndex].label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            actions: effectiveActions,
          ),
          body: body,
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

        if (isWideScreen) {
          // On desktop/Chrome, center the mobile viewport in a clean mobile frame
          return Scaffold(
            backgroundColor: const Color(
              0xFFF0EDF9,
            ), // Subtle lavender tinted backdrop
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxMobileWidth),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRect(child: scaffoldContent),
                ),
              ),
            ),
          );
        }

        return scaffoldContent;
      },
    );
  }
}
