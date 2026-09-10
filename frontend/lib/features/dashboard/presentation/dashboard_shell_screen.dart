import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_badge.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';

class DashboardShellScreen extends StatelessWidget {
  const DashboardShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Environment banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Healix Field Operations",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      "Doctor engagement, field distributions & commercial analytics",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const AppBadge(
                label: "Phase 1 Foundation",
                variant: AppBadgeVariant.info,
                icon: Icons.verified_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Foundational KPI Shell Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 768 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: const [
              _KpiShellCard(
                title: "Today's Visits",
                icon: Icons.location_on_outlined,
                accentColor: AppColors.primary,
              ),
              _KpiShellCard(
                title: "Follow-ups Due",
                icon: Icons.calendar_today_outlined,
                accentColor: AppColors.warning,
              ),
              _KpiShellCard(
                title: "Samples Given",
                icon: Icons.medication_outlined,
                accentColor: AppColors.sample,
              ),
              _KpiShellCard(
                title: "Realized Sales",
                icon: Icons.currency_rupee_outlined,
                accentColor: AppColors.paidSale,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Empty state placeholder informing user about V1 workflow
          const AppCard(
            child: AppEmptyState(
              icon: Icons.dashboard_customize_outlined,
              title: "RG WIN Application Foundation Ready",
              description:
                  "Database schema, security headers, Alembic migrations, and Flutter Material 3 design system are established. Proceeding to Phase 2 for Authentication & RBAC.",
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiShellCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;

  const _KpiShellCard({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
            ],
          ),
          const Text(
            "—",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
