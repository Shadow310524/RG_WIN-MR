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
import 'package:rgwin_crm/features/analytics/presentation/analytics_controller.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/followups/presentation/follow_up_controller.dart';
import 'package:rgwin_crm/features/promotions/presentation/promotional_investment_controller.dart';
import 'package:rgwin_crm/features/sales/domain/models/purchase_model.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/visits/domain/models/visit_model.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class DashboardShellScreen extends ConsumerStatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  ConsumerState<DashboardShellScreen> createState() =>
      _DashboardShellScreenState();
}

class _DashboardShellScreenState extends ConsumerState<DashboardShellScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = "Today"; // "Today", "This Week", "This Month"
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _entranceController.forward();
    Future.microtask(() {
      ref.read(visitControllerProvider.notifier).loadVisits();
      ref.read(purchaseControllerProvider.notifier).loadPurchases();
      ref.read(doctorControllerProvider.notifier).loadInitialData();
      ref.read(followUpControllerProvider.notifier).loadFollowUps();
      ref
          .read(promotionalInvestmentControllerProvider.notifier)
          .loadInvestments();
      ref.read(analyticsControllerProvider.notifier).loadAnalytics();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  DateTime get _now => DateTime.now();

  List<VisitModel> _filterVisitsForPeriod(List<VisitModel> visits) {
    if (_selectedPeriod == "Today") {
      return visits.where((v) {
        final d = v.visitDatetime;
        return d.year == _now.year &&
            d.month == _now.month &&
            d.day == _now.day;
      }).toList();
    } else if (_selectedPeriod == "This Week") {
      final weekAgo = _now.subtract(const Duration(days: 7));
      return visits.where((v) => v.visitDatetime.isAfter(weekAgo)).toList();
    } else {
      final monthAgo = _now.subtract(const Duration(days: 30));
      return visits.where((v) {
        final d = v.visitDatetime;
        return (d.year == _now.year && d.month == _now.month) ||
            d.isAfter(monthAgo);
      }).toList();
    }
  }

  List<PurchaseModel> _filterPurchasesForPeriod(List<PurchaseModel> purchases) {
    if (_selectedPeriod == "Today") {
      return purchases.where((p) {
        final d = p.purchaseDate;
        return d.year == _now.year &&
            d.month == _now.month &&
            d.day == _now.day;
      }).toList();
    } else if (_selectedPeriod == "This Week") {
      final weekAgo = _now.subtract(const Duration(days: 7));
      return purchases.where((p) => p.purchaseDate.isAfter(weekAgo)).toList();
    } else {
      final monthAgo = _now.subtract(const Duration(days: 30));
      return purchases.where((p) {
        final d = p.purchaseDate;
        return (d.year == _now.year && d.month == _now.month) ||
            d.isAfter(monthAgo);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final visitState = ref.watch(visitControllerProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);
    final doctorState = ref.watch(doctorControllerProvider);
    final followUpState = ref.watch(followUpControllerProvider);

    final fullName = authState.user?.fullName;
    final periodVisits = _filterVisitsForPeriod(visitState.visits);
    final periodPurchases = _filterPurchasesForPeriod(purchaseState.purchases);
    final periodPurchaseAmount = periodPurchases.fold(
      0.0,
      (sum, p) => sum + p.purchaseAmount,
    );
    final pendingFollowUps = followUpState.followUps
        .where((f) => !f.isCompleted)
        .toList();
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
          ref
              .read(promotionalInvestmentControllerProvider.notifier)
              .loadInvestments(),
          ref.read(analyticsControllerProvider.notifier).loadAnalytics(),
        ]);
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Field Sales Executive Header
                _buildExecutiveHeader(fullName, authState.user?.role),
                const SizedBox(height: AppSpacing.md),

                // 2. Period Selector (Today | This Week | This Month)
                _buildPeriodSelector(),
                const SizedBox(height: AppSpacing.lg),

                // 3. 4-KPI Overview Grid (Visits, Purchases, Follow-ups, Doctors)
                _buildKpiGrid(
                  visitsCount: periodVisits.length,
                  purchaseAmount: periodPurchaseAmount,
                  pendingFollowUpsCount: pendingFollowUps.length,
                  totalDoctorsCount: doctorState.doctors.length,
                ),
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
        ),
      ),
    );
  }

  Widget _buildExecutiveHeader(String? fullName, String? role) {
    final hasName = fullName != null && fullName.trim().isNotEmpty;
    final firstName = hasName ? fullName.trim().split(' ').first : null;
    final greetingTitle = hasName
        ? "${_getGreeting()}, $firstName 👋"
        : "${_getGreeting()} 👋";
    final greetingSubtitle = hasName
        ? "Field Sales Overview"
        : "Here's your field summary";

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
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    greetingSubtitle,
                    style: const TextStyle(
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

  Widget _buildKpiGrid({
    required int visitsCount,
    required double purchaseAmount,
    required int pendingFollowUpsCount,
    required int totalDoctorsCount,
  }) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    final periodLabel = _selectedPeriod == "Today"
        ? "Today's"
        : (_selectedPeriod == "This Week" ? "Weekly" : "Monthly");

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Column(
        key: ValueKey(_selectedPeriod),
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: "$periodLabel Visits",
                  value: "$visitsCount",
                  icon: Icons.calendar_today_rounded,
                  accentColor: AppColors.primary,
                  subtitle: "Logged visits",
                  onTap: () => context.push('/visits'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MetricCard(
                  title: "$periodLabel Purchases",
                  value: currencyFormatter.format(purchaseAmount),
                  icon: Icons.shopping_bag_outlined,
                  accentColor: AppColors.secondary,
                  subtitle: "Booked overall",
                  onTap: () => context.push('/sales'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: "Follow-ups",
                  value: "$pendingFollowUpsCount",
                  icon: Icons.event_note_outlined,
                  accentColor: AppColors.warning,
                  subtitle: "Pending tasks",
                  onTap: () => context.push('/followups'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MetricCard(
                  title: "Doctors",
                  value: "$totalDoctorsCount",
                  icon: Icons.people_outline_rounded,
                  accentColor: AppColors.info,
                  subtitle: "Territory directory",
                  onTap: () => context.push('/doctors'),
                ),
              ),
            ],
          ),
        ],
      ),
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
                  onTap: () => context.push('/visits/add'),
                ),
              ),
              Expanded(
                child: QuickActionItem(
                  label: "Add Doctor",
                  icon: Icons.person_add_alt_1_outlined,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.secondaryLight,
                  onTap: () => context.push('/doctors/add'),
                ),
              ),
              Expanded(
                child: QuickActionItem(
                  label: "Purchase",
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.success,
                  backgroundColor: AppColors.successLight,
                  onTap: () => context.push('/sales/record'),
                ),
              ),
              Expanded(
                child: QuickActionItem(
                  label: "Expense",
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.warning,
                  backgroundColor: AppColors.warningLight,
                  onTap: () => context.push('/expenses/add'),
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
          onAction: () => context.push('/visits'),
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
                    onTap: () => context.push('/visits/add'),
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
                onTap: () => context.push('/visits'),
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
          onAction: () => context.push('/followups'),
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
                onTap: () {
                  if (fu.doctorId.isNotEmpty) {
                    context.push('/doctors/${fu.doctorId}');
                  } else {
                    context.push('/followups');
                  }
                },
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

    // Group real purchases by doctorId
    final Map<String, double> purchasesByDoctor = {};
    for (final p in purchaseState.purchases) {
      if (p.doctorId != null && p.doctorId!.isNotEmpty) {
        purchasesByDoctor[p.doctorId!] =
            (purchasesByDoctor[p.doctorId!] ?? 0.0) + p.purchaseAmount;
      }
    }

    // Filter and sort doctors by actual purchase volume descending
    final purchasingDoctors =
        doctorState.doctors
            .where(
              (d) =>
                  purchasesByDoctor.containsKey(d.id) &&
                  purchasesByDoctor[d.id]! > 0,
            )
            .toList()
          ..sort(
            (a, b) =>
                purchasesByDoctor[b.id]!.compareTo(purchasesByDoctor[a.id]!),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Top Purchasing Doctors",
          subtitle: "Key medical business relationships",
          actionLabel: "Directory",
          onAction: () => context.push('/doctors'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (purchasingDoctors.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                "No purchase data recorded yet.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: purchasingDoctors.length > 3
                ? 3
                : purchasingDoctors.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final doc = purchasingDoctors[index];
              final amount = purchasesByDoctor[doc.id] ?? 0.0;

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.push('/doctors/${doc.id}'),
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
                value: "Revenue unavailable",
                isMuted: true,
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
