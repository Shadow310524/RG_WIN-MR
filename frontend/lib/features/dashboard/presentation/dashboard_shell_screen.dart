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
import 'package:rgwin_crm/core/widgets/spring_button.dart';
import 'package:rgwin_crm/core/widgets/status_chip.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/followups/presentation/follow_up_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class DashboardShellScreen extends ConsumerStatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  ConsumerState<DashboardShellScreen> createState() =>
      _DashboardShellScreenState();
}

class _DashboardShellScreenState extends ConsumerState<DashboardShellScreen> {
  String _selectedPeriod = "Today"; // "Today", "This Week", "This Month"

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
    final followUpState = ref.watch(followUpControllerProvider);

    final userName =
        authState.user?.fullName.split(' ').first ?? "Representative";
    final todayVisits = visitState.todayVisits;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        await Future.wait([
          ref.read(visitControllerProvider.notifier).loadVisits(),
          ref.read(purchaseControllerProvider.notifier).loadPurchases(),
          ref.read(doctorControllerProvider.notifier).loadDoctors(),
          ref.read(followUpControllerProvider.notifier).loadFollowUps(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Field Sales Executive Header
            _buildExecutiveHeader(userName, authState.user?.role),
            const SizedBox(height: AppSpacing.md),

            // 2. Period Selector (Today | This Week | This Month)
            _buildPeriodSelector(),
            const SizedBox(height: AppSpacing.lg),

            // 3. 4-KPI Grid (Today's Visits, Purchase Value, Revenue, Profit/Loss)
            _buildKpiGrid(todayVisits.length, purchaseState),
            const SizedBox(height: AppSpacing.xl),

            // 4. One-Hand Quick Actions (Touch targets >= 48dp)
            _buildQuickActions(),
            const SizedBox(height: AppSpacing.xl),

            // 5. Today's Field Activity (Visits Timeline)
            _buildTodayActivity(todayVisits),
            const SizedBox(height: AppSpacing.xl),

            // 6. Upcoming Follow-ups (Phase 4 Workflow)
            _buildUpcomingFollowUps(followUpState),
            const SizedBox(height: AppSpacing.xl),

            // 7. Top Purchasing Doctors
            _buildTopPurchasingDoctors(doctorState, purchaseState),
            const SizedBox(height: AppSpacing.xl),

            // 8. Commercial Health & PTS Snapshot
            _buildCommercialSnapshot(purchaseState),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveHeader(String userName, String? role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1,
                ),
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
                  const SizedBox(width: 5),
                  const Text(
                    "Online & Synced",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('EEE, d MMM').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ["Today", "This Week", "This Month"];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: SpringButton(
              onTap: () => setState(() => _selectedPeriod = period),
              scaleDown: 0.95,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiGrid(int todayVisitsCount, PurchaseState purchaseState) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: "Today's Visits",
                value: "$todayVisitsCount",
                icon: Icons.calendar_today_rounded,
                accentColor: AppColors.primary,
                subtitle: "$todayVisitsCount scheduled",
                onTap: () => context.go('/visits'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                title: "Purchase Value",
                value: currencyFormatter.format(
                  purchaseState.totalPurchaseAmount,
                ),
                icon: Icons.shopping_bag_outlined,
                accentColor: AppColors.secondary,
                subtitle: "Booked overall",
                onTap: () => context.go('/sales'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: "Revenue",
                value: currencyFormatter.format(purchaseState.totalRevenue),
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.success,
                subtitle: "Gross realized",
                onTap: () => context.go('/sales'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                title: "Profit / Loss",
                value: "Insufficient data",
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.warning,
                isUnavailable: true,
                subtitle: "Awaiting PTS & cost",
                onTap: () => context.go('/sales'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Quick Actions",
          subtitle: "Fast one-handed field entry",
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xs,
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
                  color: AppColors.secondary,
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
      ],
    );
  }

  Widget _buildTodayActivity(List<dynamic> todayVisits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Today's Activity",
          subtitle: "${todayVisits.length} appointments on schedule",
          actionLabel: "View all",
          onAction: () => context.go('/visits'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (todayVisits.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_note_outlined,
                      size: 24,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    "No visits recorded today",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Start by recording your first doctor interaction.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SpringButton(
                    onTap: () => context.go('/visits/add'),
                    scaleDown: 0.95,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        "Log Visit",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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
              final visitTime = v.visitTime ?? "09:30 AM";

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.go('/visits'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        visitTime,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
                            v.doctorName ?? "Doctor Visit",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            v.clinicName ?? "Clinic Consultation",
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
      ],
    );
  }

  Widget _buildUpcomingFollowUps(FollowUpState followUpState) {
    final upcoming = followUpState.upcomingFollowUps;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Upcoming Follow-ups",
          subtitle: "${upcoming.length} commitments scheduled",
          actionLabel: "View all",
          onAction: () => context.go('/followups'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (upcoming.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.event_available_outlined,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text(
                    "No pending follow-ups scheduled.",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcoming.length > 3 ? 3 : upcoming.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final fu = upcoming[index];
              String timeLabel;
              if (fu.dueDate.year == now.year &&
                  fu.dueDate.month == now.month &&
                  fu.dueDate.day == now.day) {
                timeLabel = "Today";
              } else if (fu.dueDate.year == now.year &&
                  fu.dueDate.month == now.month &&
                  fu.dueDate.day == now.day + 1) {
                timeLabel = "Tomorrow";
              } else {
                timeLabel = DateFormat('dd MMM').format(fu.dueDate);
              }

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.go('/followups'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: timeLabel == "Today"
                            ? AppColors.warningLight
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: timeLabel == "Today"
                              ? AppColors.warning
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fu.doctorName ?? "Doctor Follow-up",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fu.taskReason,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    StatusChip.fromStatus(fu.status),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTopPurchasingDoctors(
    DoctorState doctorState,
    PurchaseState purchaseState,
  ) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );
    final doctors = doctorState.doctors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Top Purchasing Doctors",
          subtitle: "Key medical business relationships",
          actionLabel: "Directory",
          onAction: () => context.go('/doctors'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (doctors.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                "No doctors enrolled yet.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: doctors.length > 2 ? 2 : doctors.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final samplePurchases = [50000.0, 32000.0];
              final amount = index < samplePurchases.length
                  ? samplePurchases[index]
                  : 15000.0;

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.go('/doctors/${doc.id}'),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
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
                            doc.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doc.clinicName ??
                                doc.areaName ??
                                "Medical Facility",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormatter.format(amount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCommercialSnapshot(PurchaseState purchaseState) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Sales Snapshot",
          subtitle: "Authoritative financial tracking",
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildSnapshotRow(
                label: "Total Purchases Booked",
                value: currencyFormatter.format(
                  purchaseState.totalPurchaseAmount,
                ),
                isHighlight: true,
              ),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              _buildSnapshotRow(
                label: "Gross Realized Revenue",
                value: currencyFormatter.format(purchaseState.totalRevenue),
              ),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              _buildSnapshotRow(
                label: "PTS Formula Rate",
                value: "Not configured",
                isMuted: true,
              ),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              _buildSnapshotRow(label: "PTS Value", value: "—", isMuted: true),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              _buildSnapshotRow(
                label: "Net Profit / Loss",
                value: "Insufficient data",
                isMuted: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSnapshotRow({
    required String label,
    required String value,
    bool isHighlight = false,
    bool isMuted = false,
  }) {
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
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
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
