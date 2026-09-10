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
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class DashboardShellScreen extends ConsumerStatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  ConsumerState<DashboardShellScreen> createState() =>
      _DashboardShellScreenState();
}

class _DashboardShellScreenState extends ConsumerState<DashboardShellScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = "TODAY"; // "TODAY", "WEEK", "MONTH"
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
      color: AppColors.primaryGlow,
      backgroundColor: AppColors.surfaceElevated,
      onRefresh: () async {
        await Future.wait([
          ref.read(visitControllerProvider.notifier).loadVisits(),
          ref.read(purchaseControllerProvider.notifier).loadPurchases(),
          ref.read(doctorControllerProvider.notifier).loadDoctors(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          100, // Padding for floating glass dock
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Executive MR Command Header
            _buildAnimatedItem(
              intervalStart: 0.0,
              intervalEnd: 0.4,
              child: _buildExecutiveHeader(userName, authState.user?.role),
            ),
            const SizedBox(height: AppSpacing.md),

            // Period Selector Chip Group with smooth animation
            _buildAnimatedItem(
              intervalStart: 0.1,
              intervalEnd: 0.5,
              child: _buildPeriodSelector(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Luminous Executive Commercial Hero Cockpit
            _buildAnimatedItem(
              intervalStart: 0.2,
              intervalEnd: 0.6,
              child: _buildHeroCommercialCockpit(purchaseState, todayVisits),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 3. Tactile Bento Quick Action Dock (4 items)
            _buildAnimatedItem(
              intervalStart: 0.35,
              intervalEnd: 0.75,
              child: _buildBentoQuickActions(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Today's Mission Radar (Visits Schedule)
            _buildAnimatedItem(
              intervalStart: 0.5,
              intervalEnd: 0.9,
              child: _buildMissionRadar(todayVisits),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 5. Territory Performance Matrix
            _buildAnimatedItem(
              intervalStart: 0.65,
              intervalEnd: 1.0,
              child: _buildTerritoryMatrix(doctorState),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 6. Commercial Health & P&L Snapshot
            _buildCommercialSnapshot(purchaseState),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({
    required double intervalStart,
    required double intervalEnd,
    required Widget child,
  }) {
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildExecutiveHeader(String userName, String? role) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "ONLINE & SYNCED",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
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
              const SizedBox(height: 6),
              Text(
                "${_getGreeting()}, $userName 👋",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Field Sales Overview",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ["TODAY", "WEEK", "MONTH"];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: SpringButton(
              onTap: () => setState(() => _selectedPeriod = period),
              scaleDown: 0.94,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    period == "TODAY"
                        ? "Today"
                        : (period == "WEEK" ? "This Week" : "This Month"),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      letterSpacing: -0.2,
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

  Widget _buildHeroCommercialCockpit(
    PurchaseState purchaseState,
    List<dynamic> todayVisits,
  ) {
    final totalSales = purchaseState.totalPurchaseAmount;
    final totalRevenue = purchaseState.totalRevenue;
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return AppCard(
      isGlass: true,
      gradient: AppColors.heroCardGradient,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.primaryGlow.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: AppColors.primaryGlow,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Flexible(
                      child: Text(
                        "COMMERCIAL TELEMETRY",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: AppColors.primaryGlow.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  "PTS Telemetry",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGlow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Total Realized Commercial Value
          Text(
            formatter.format(totalSales),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -1.0,
            ),
          ),
          const Text(
            "Overall Purchases Booked",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Metric Sub-Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  label: "Gross Revenue",
                  value: formatter.format(totalRevenue),
                  color: AppColors.success,
                  icon: Icons.monetization_on_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMiniMetric(
                  label: "PTS Est. Yield",
                  value: "—",
                  color: AppColors.primaryGlow,
                  icon: Icons.percent_rounded,
                  badge: "Pending",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Quick Action Dock",
          subtitle: "Tactile one-touch field actions",
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          isGlass: true,
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
                  icon: Icons.add_location_alt_rounded,
                  color: AppColors.primaryGlow,
                  backgroundColor: AppColors.primaryLight,
                  onTap: () => context.go('/visits/add'),
                ),
              ),
              Expanded(
                child: QuickActionItem(
                  label: "Add Doctor",
                  icon: Icons.person_add_alt_1_rounded,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.secondaryLight,
                  onTap: () => context.go('/doctors/add'),
                ),
              ),
              Expanded(
                child: QuickActionItem(
                  label: "Purchase",
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.success,
                  backgroundColor: AppColors.successLight,
                  onTap: () => context.go('/sales/record'),
                ),
              ),
              Expanded(
                child: QuickActionItem(
                  label: "Expense",
                  icon: Icons.account_balance_wallet_rounded,
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

  Widget _buildMissionRadar(List<dynamic> todayVisits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Today's Mission Radar",
          subtitle: "${todayVisits.length} appointments on daily roster",
          actionLabel: "View all",
          onAction: () => context.go('/visits'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (todayVisits.isEmpty)
          AppCard(
            isGlass: true,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGlow.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      size: 26,
                      color: AppColors.primaryGlow,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    "Clear Runway Today",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "No scheduled visits for today yet.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SpringButton(
                    onTap: () => context.go('/visits/add'),
                    scaleDown: 0.94,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        "Schedule Next Visit",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
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
              return AppCard(
                isGlass: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.go('/visits'),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.primaryGlow.withOpacity(0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.medical_services_rounded,
                          size: 20,
                          color: AppColors.primaryGlow,
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

  Widget _buildTerritoryMatrix(DoctorState doctorState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Territory Matrix",
          subtitle: "Network coverage & active doctor reach",
          actionLabel: "Directory",
          onAction: () => context.go('/doctors'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: "Enrolled Doctors",
                value: "${doctorState.total}",
                icon: Icons.people_alt_rounded,
                accentColor: AppColors.primaryGlow,
                subtitle: "${doctorState.doctors.length} locally cached",
                onTap: () => context.go('/doctors'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                title: "Territory Reach",
                value: "${doctorState.areas.length} Areas",
                icon: Icons.map_rounded,
                accentColor: AppColors.secondary,
                subtitle: "Assigned territory",
                onTap: () => context.go('/doctors'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommercialSnapshot(PurchaseState purchaseState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Executive Commercial Health",
          subtitle: "Gross financial indicators & profit telemetry",
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          isGlass: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildSnapshotRow(
                label: "Gross Purchase Value",
                value: NumberFormat.currency(
                  locale: 'en_IN',
                  symbol: '₹',
                ).format(purchaseState.totalPurchaseAmount),
                isHighlight: true,
              ),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              _buildSnapshotRow(
                label: "Realized Revenue (Net + Tax)",
                value: NumberFormat.currency(
                  locale: 'en_IN',
                  symbol: '₹',
                ).format(purchaseState.totalRevenue),
              ),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              _buildSnapshotRow(
                label: "PTS Formula Rate",
                value: "Calculating / Not configured",
                isMuted: true,
              ),
              const Divider(height: AppSpacing.lg, color: AppColors.border),
              _buildSnapshotRow(
                label: "Net Profit / Loss",
                value: "Profit/Loss unavailable",
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
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight
                ? AppColors.primaryGlow
                : (isMuted ? AppColors.textMuted : AppColors.textPrimary),
            fontStyle: isMuted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
