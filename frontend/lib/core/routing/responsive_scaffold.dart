import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';
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

class ResponsiveScaffold extends ConsumerStatefulWidget {
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
  ConsumerState<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends ConsumerState<ResponsiveScaffold> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final defaultActions = <Widget>[
      if (authState.user != null) ...[
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  authState.user!.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          icon: const Icon(
            Icons.logout_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          tooltip: 'Sign Out (${authState.user!.fullName})',
          onPressed: () => ref.read(authProvider.notifier).logout(),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    ];

    final effectiveActions = widget.actions ?? defaultActions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen =
            constraints.maxWidth > ResponsiveScaffold.kMaxMobileWidth;

        final scaffoldContent = PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            final now = DateTime.now();
            if (_lastBackPressTime != null &&
                now.difference(_lastBackPressTime!) <
                    const Duration(seconds: 2)) {
              SystemNavigator.pop();
            } else {
              _lastBackPressTime = now;
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Press back again to exit",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.textPrimary.withOpacity(0.88),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  margin: const EdgeInsets.only(
                    bottom: 74,
                    left: 70,
                    right: 70,
                  ),
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
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
                    widget.title ?? widget.items[widget.currentIndex].label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              actions: effectiveActions,
            ),
            body: widget.body,
            floatingActionButton: widget.floatingActionButton,
            bottomNavigationBar: _MobileBottomNav(
              currentIndex: widget.currentIndex,
              items: widget.items,
              onSelected: widget.onNavigationIndexChanged,
            ),
          ),
        );

        if (isWideScreen) {
          // On desktop/Chrome web testing, center within standard mobile dimensions
          return Scaffold(
            backgroundColor: const Color(0xFFF0EFF6),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ResponsiveScaffold.kMaxMobileWidth,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 24,
                        offset: Offset(0, 4),
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

/// Clean, high-performance mobile bottom navigation bar with soft lavender active states.
class _MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onSelected;

  const _MobileBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x06202033),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: SpringButton(
                  onTap: () => onSelected(index),
                  scaleDown: 0.94,
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textMuted,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
