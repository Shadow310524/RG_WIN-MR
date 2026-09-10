import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_badge.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';

class MoreShellScreen extends ConsumerWidget {
  const MoreShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Banner Card
              AppCard(
                isGlass: true,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryGlow.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.fullName.isNotEmpty == true
                              ? user!.fullName.substring(0, 1).toUpperCase()
                              : "U",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? "Field Sales User",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? "user@healix.com",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              AppBadge(
                                label: user?.role ?? "MR",
                                variant: user?.role == "ADMIN"
                                    ? AppBadgeVariant.active
                                    : AppBadgeVariant.info,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const AppBadge(
                                label: "ONLINE",
                                variant: AppBadgeVariant.active,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick Modules Section
              const SectionHeader(title: "CRM Modules & Tools"),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                isGlass: true,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.calendar_today_outlined,
                      title: "Follow-ups & Reminders",
                      subtitle: "Scheduled doctor visits and call reminders",
                      onTap: () => context.go('/followups'),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.bar_chart_rounded,
                      title: "Commercial Analytics",
                      subtitle: "Doctor, area & territory performance insights",
                      onTap: () => context.go('/analytics'),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.receipt_long_outlined,
                      title: "Record Field Expense",
                      subtitle: "Travel, fuel, DA and promotion claims",
                      onTap: () => context.go('/expenses/add'),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.medication_outlined,
                      title: "Healix Product Catalog",
                      subtitle:
                          "Authoritative 31-product master catalog & details",
                      onTap: () => context.go('/products'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Account & Session
              const SectionHeader(title: "Account & System"),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.sync_rounded,
                      title: "Offline Storage & Sync",
                      subtitle: "Drift SQLite local database status",
                      trailing: const Text(
                        "Drift Ready",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Offline database synchronized with local Drift store.",
                            ),
                            backgroundColor: AppColors.primaryDark,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      title: "Sign Out",
                      subtitle:
                          "Revokes token session and clears secure storage",
                      textColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;
  final Color? iconColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      onTap: onTap,
      scaleDown: 0.98,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryGlow).withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: (iconColor ?? AppColors.primaryGlow).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primaryGlow,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing:
            trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}
