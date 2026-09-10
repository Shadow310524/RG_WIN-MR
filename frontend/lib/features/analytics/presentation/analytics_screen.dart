import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_loading_indicator.dart';
import 'package:rgwin_crm/core/widgets/metric_card.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/features/analytics/domain/models/analytics_models.dart';
import 'package:rgwin_crm/features/analytics/presentation/analytics_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsControllerProvider);
    final summary = state.overallSummary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Commercial Analytics"),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
            ),
            tooltip: "Financial Provenance",
            onPressed: () => _showProvenanceInfo(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: "Refresh Analytics",
            onPressed: () =>
                ref.read(analyticsControllerProvider.notifier).loadAnalytics(),
          ),
        ],
      ),
      body: state.isLoading && summary == null
          ? const Center(
              child: AppLoadingIndicator(
                message: "Aggregating commercial analytics...",
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(analyticsControllerProvider.notifier)
                  .loadAnalytics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Period Selector Chips
                    _PeriodSelector(
                      currentPeriod: state.period,
                      onSelected: (p) => ref
                          .read(analyticsControllerProvider.notifier)
                          .setPeriod(p),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 2. Executive Business Overview
                    const SectionHeader(
                      title: "Business Overview",
                      subtitle:
                          "Authoritative realized business vs promotional spend",
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (summary != null)
                      _BusinessOverviewCard(summary: summary)
                    else
                      const AppCard(
                        child: Text("No commercial data available."),
                      ),
                    const SizedBox(height: AppSpacing.md),

                    // 3. Provenance & Attribution Banner
                    _ProvenanceBanner(
                      onTap: () => _showProvenanceInfo(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 4. Area Performance (Derived purely from assigned doctors)
                    SectionHeader(
                      title: "Area Performance",
                      subtitle: "Commercial rollups with doctor drill-down",
                      actionLabel: summary != null
                          ? "${summary.areas.length} Areas"
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (summary == null || summary.areas.isEmpty)
                      const AppCard(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(
                            child: Text(
                              "No assigned areas with activity in this period.",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ...summary.areas.map(
                        (area) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _AreaPerformanceCard(
                            area: area,
                            onTap: () => _showAreaDrilldown(context, area),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),

                    // 5. Doctor Performance (Top Contributors)
                    const SectionHeader(
                      title: "Doctor Performance",
                      subtitle:
                          "Top contributing doctors ranked by business value",
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (summary == null || summary.topDoctors.isEmpty)
                      const AppCard(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(
                            child: Text(
                              "No doctor purchase activity in this period.",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      AppCard(
                        child: Column(
                          children: summary.topDoctors.asMap().entries.map((
                            entry,
                          ) {
                            final idx = entry.key;
                            final doc = entry.value;
                            return _DoctorRankRow(
                              rank: idx + 1,
                              doctor: doc,
                              onTap: () =>
                                  context.push('/doctors/${doc.doctorId}'),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }

  void _showProvenanceInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  "Financial Data Provenance",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              "RG WIN maintains strict financial integrity without invented numbers:",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            _ProvenanceItem(
              title: "Business Value",
              source: "Realized Purchases",
              desc:
                  "Direct sum of commercial purchases recorded in field sales workflow.",
              color: AppColors.success,
            ),
            _ProvenanceItem(
              title: "Promotional Investment",
              source: "Explicit Doctor Spend",
              desc:
                  "Attributable cost of samples, promotional units, and free supplies specifically entered.",
              color: AppColors.primaryDark,
            ),
            _ProvenanceItem(
              title: "Revenue / Margin",
              source: "Revenue unavailable",
              desc:
                  "Pending authoritative price-to-stockist (PTS) formula and Healix product margin tables.",
              color: AppColors.warning,
            ),
            _ProvenanceItem(
              title: "General Expenses",
              source: "Operating Expenses (Excluded)",
              desc:
                  "Food, fuel, and travel are tracked separately and NOT deducted from individual doctor worth.",
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showAreaDrilldown(
    BuildContext context,
    AreaCommercialSummaryModel area,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.areaName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Area Code: ${area.areaCode} • ${area.doctorCount} Enrolled Doctors",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      "₹${NumberFormat('#,##,###.00').format(area.businessValue)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                "DOCTOR COMMERCIAL RANKING (BY BUSINESS VALUE)",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: area.doctors.isEmpty
                    ? const Center(
                        child: Text(
                          "No doctors assigned to this area yet.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: area.doctors.length,
                        itemBuilder: (context, index) {
                          final doc = area.doctors[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              context.push('/doctors/${doc.doctorId}');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.border,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: index == 0
                                        ? AppColors.primaryDark
                                        : AppColors.primaryLight,
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: index == 0
                                            ? Colors.white
                                            : AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc.doctorName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          "${doc.specialization}${doc.clinicName != null ? ' • ${doc.clinicName}' : ''}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Promo Spend: ₹${NumberFormat('#,##,###.00').format(doc.promotionalInvestment)}",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₹${NumberFormat('#,##,###.00').format(doc.businessValue)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const Text(
                                        "View Profile →",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final String currentPeriod;
  final ValueChanged<String> onSelected;

  const _PeriodSelector({
    required this.currentPeriod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      {"id": "today", "label": "Today"},
      {"id": "this_week", "label": "This Week"},
      {"id": "this_month", "label": "This Month"},
      {"id": "all", "label": "All Time"},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: periods.map((p) {
          final isSelected = currentPeriod == p["id"];
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(p["id"]!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Center(
                  child: Text(
                    p["label"]!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
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
}

class _BusinessOverviewCard extends StatelessWidget {
  final OverallCommercialSummaryModel summary;

  const _BusinessOverviewCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: "Business Value",
                  value:
                      "₹${NumberFormat('#,##,###.00').format(summary.businessValue)}",
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: AppColors.success,
                  subtitle: "Realized field purchases",
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MetricCard(
                  title: "Promotional Spend",
                  value:
                      "₹${NumberFormat('#,##,###.00').format(summary.promotionalInvestment)}",
                  icon: Icons.inventory_2_outlined,
                  accentColor: AppColors.primaryDark,
                  subtitle: "Doctor-specific samples/units",
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: "Revenue",
                  value: "Unavailable",
                  icon: Icons.currency_rupee,
                  accentColor: AppColors.textSecondary,
                  subtitle: "Pending PTS/margin formula",
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MetricCard(
                  title: "Profit / Loss",
                  value: "Insufficient data",
                  icon: Icons.analytics_outlined,
                  accentColor: AppColors.textSecondary,
                  subtitle: "Pending product cost rules",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProvenanceBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ProvenanceBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.shield_outlined, size: 18, color: AppColors.primaryDark),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                "Data Provenance: General operating expenses (food, fuel, lodging) are kept separate and not deducted from doctor commercial worth.",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaPerformanceCard extends StatelessWidget {
  final AreaCommercialSummaryModel area;
  final VoidCallback onTap;

  const _AreaPerformanceCard({required this.area, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Icon(
                Icons.location_city_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.areaName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "${area.doctorCount} Doctors • Promo Spend: ₹${NumberFormat('#,##,###.00').format(area.promotionalInvestment)}",
                  style: const TextStyle(
                    fontSize: 11,
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
                "₹${NumberFormat('#,##,###.00').format(area.businessValue)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const Row(
                children: [
                  Text(
                    "Drill-down",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorRankRow extends StatelessWidget {
  final int rank;
  final DoctorRankItemModel doctor;
  final VoidCallback onTap;

  const _DoctorRankRow({
    required this.rank,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? AppColors.primaryLight
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "$rank",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: rank <= 3
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.doctorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "${doctor.specialization}${doctor.clinicName != null ? ' • ${doctor.clinicName}' : ''}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${NumberFormat('#,##,###.00').format(doctor.businessValue)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Promo: ₹${NumberFormat('#,##,###.00').format(doctor.promotionalInvestment)}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProvenanceItem extends StatelessWidget {
  final String title;
  final String source;
  final String desc;
  final Color color;

  const _ProvenanceItem({
    required this.title,
    required this.source,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "($source)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
