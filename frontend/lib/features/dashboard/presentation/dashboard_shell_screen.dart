import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/metric_card.dart';
import 'package:rgwin_crm/core/widgets/quick_action.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/core/widgets/status_chip.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class DashboardShellScreen extends ConsumerStatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  ConsumerState<DashboardShellScreen> createState() =>
      _DashboardShellScreenState();
}

class _DashboardShellScreenState extends ConsumerState<DashboardShellScreen> {
  String _selectedPeriod = "TODAY"; // "TODAY", "WEEK", "MONTH"

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final visitState = ref.watch(visitControllerProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);
    final doctorState = ref.watch(doctorControllerProvider);

    final userName =
        authState.user?.fullName.split(' ').first ?? "Representative";
    final todayVisits = visitState.todayVisits;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(visitControllerProvider.notifier).loadVisits(),
          ref.read(purchaseControllerProvider.notifier).loadPurchases(),
          ref.read(doctorControllerProvider.notifier).loadDoctors(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Executive / MR Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_getGreeting()}, $userName 👋",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Field Sales Overview",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Period Selector Chip Group
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PeriodButton(
                    label: "Today",
                    isSelected: _selectedPeriod == "TODAY",
                    onTap: () => setState(() => _selectedPeriod = "TODAY"),
                  ),
                  _PeriodButton(
                    label: "This Week",
                    isSelected: _selectedPeriod == "WEEK",
                    onTap: () => setState(() => _selectedPeriod = "WEEK"),
                  ),
                  _PeriodButton(
                    label: "This Month",
                    isSelected: _selectedPeriod == "MONTH",
                    onTap: () => setState(() => _selectedPeriod = "MONTH"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Mobile KPI Cards (2x2 Grid)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.35,
              children: [
                MetricCard(
                  title: "Today's Visits",
                  value: "${todayVisits.length}",
                  icon: Icons.location_on_outlined,
                  accentColor: AppColors.primaryDark,
                  subtitle: todayVisits.isEmpty
                      ? "No visits yet"
                      : "Scheduled / Done",
                  onTap: () => context.go('/visits'),
                ),
                MetricCard(
                  title: "Purchase Value",
                  value:
                      "₹${NumberFormat('#,##,###').format(purchaseState.totalPurchaseAmount)}",
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: AppColors.primary,
                  subtitle: "Overall gross value",
                  onTap: () => context.go('/sales'),
                ),
                MetricCard(
                  title: "Revenue",
                  value:
                      "₹${NumberFormat('#,##,###').format(purchaseState.totalRevenue)}",
                  icon: Icons.currency_rupee,
                  accentColor: AppColors.success,
                  subtitle: "Realized sales",
                  onTap: () => context.go('/sales'),
                ),
                const MetricCard(
                  title: "Profit / Loss",
                  value: "—",
                  icon: Icons.query_stats,
                  accentColor: AppColors.textMuted,
                  isUnavailable: true,
                  subtitle: "Insufficient data",
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 3. One-Hand Quick Actions (4 items)
            const SectionHeader(
              title: "Quick Actions",
              subtitle: "Common field sales tasks",
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: QuickActionItem(
                      label: "Add Visit",
                      icon: Icons.add_location_alt_outlined,
                      color: AppColors.primaryDark,
                      backgroundColor: AppColors.primaryLight,
                      onTap: () => context.go('/visits/add'),
                    ),
                  ),
                  Expanded(
                    child: QuickActionItem(
                      label: "Add Doctor",
                      icon: Icons.person_add_alt_1_outlined,
                      color: AppColors.secondaryDark,
                      backgroundColor: AppColors.secondaryLight,
                      onTap: () => context.go('/doctors/add'),
                    ),
                  ),
                  Expanded(
                    child: QuickActionItem(
                      label: "Purchase",
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.success,
                      backgroundColor: AppColors.successLight,
                      onTap: () => context.go('/sales/record'),
                    ),
                  ),
                  Expanded(
                    child: QuickActionItem(
                      label: "Expense",
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.warning,
                      backgroundColor: AppColors.warningLight,
                      onTap: () => context.go('/expenses/add'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Today's Activity / Visits Schedule
            SectionHeader(
              title: "Today's Activity",
              subtitle: "${todayVisits.length} visits on schedule",
              actionLabel: "View all",
              onAction: () => context.go('/visits'),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (todayVisits.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryVeryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "No visits recorded today",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Tap 'Add Visit' to log your first interaction.",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayVisits.length > 3 ? 3 : todayVisits.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final v = todayVisits[index];
                  return AppCard(
                    onTap: () => context.go('/doctors/${v.doctorId}'),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(v.visitDatetime),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.doctorName ?? "Dr. Medical Professional",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                v.clinicName ?? "General Clinic",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip.fromStatus(v.status),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.xl),

            // 5. Sales Snapshot
            const SectionHeader(
              title: "Sales Snapshot",
              subtitle: "Commercial performance & PTS summary",
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                children: [
                  _SnapshotRow(
                    label: "Purchase Value",
                    value:
                        "₹${NumberFormat('#,##,###').format(purchaseState.totalPurchaseAmount)}",
                    isHighlight: true,
                  ),
                  const Divider(height: AppSpacing.md),
                  _SnapshotRow(
                    label: "Revenue",
                    value:
                        "₹${NumberFormat('#,##,###').format(purchaseState.totalRevenue)}",
                  ),
                  const Divider(height: AppSpacing.md),
                  const _SnapshotRow(
                    label: "PTS",
                    value: "Calculating / Pending",
                    isMuted: true,
                  ),
                  const Divider(height: AppSpacing.md),
                  const _SnapshotRow(
                    label: "Profit / Loss",
                    value: "Profit/Loss unavailable",
                    isMuted: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 6. Top Doctors / Medicals
            SectionHeader(
              title: "Top Purchase Doctors",
              subtitle: "Territory high-value relationships",
              actionLabel: "View all",
              onAction: () => context.go('/doctors'),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (doctorState.doctors.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    "No doctor relationships enrolled yet.",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctorState.doctors.length > 3
                    ? 3
                    : doctorState.doctors.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final doc = doctorState.doctors[index];
                  final docPurchases = purchaseState.purchases
                      .where((p) => p.doctorId == doc.id)
                      .toList();
                  final total = docPurchases.fold(
                    0.0,
                    (sum, p) => sum + p.totalAmount,
                  );

                  return AppCard(
                    onTap: () => context.go('/doctors/${doc.id}'),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                doc.clinicName ?? doc.specialization,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              total > 0
                                  ? "₹${NumberFormat('#,##,###').format(total)}"
                                  : "Active",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: total > 0
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "View Profile →",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isMuted;

  const _SnapshotRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight
                ? AppColors.primaryDark
                : (isMuted ? AppColors.textMuted : AppColors.textPrimary),
            fontStyle: isMuted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
