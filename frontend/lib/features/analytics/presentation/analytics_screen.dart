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
                    // 1. Offline Cache Notice Banner
                    if (state.isCached) ...[
                      _CacheNoticeBanner(
                        lastUpdated: state.lastUpdated,
                        onRefresh: () => ref
                            .read(analyticsControllerProvider.notifier)
                            .loadAnalytics(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // 2. Period Selector Chips
                    _PeriodSelector(
                      currentPeriod: state.period,
                      onSelected: (p) => ref
                          .read(analyticsControllerProvider.notifier)
                          .setPeriod(p),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 3. Field Activity Overview (Visits, Purchases, Followups)
                    if (summary != null) ...[
                      const SectionHeader(
                        title: "Field Activity Summary",
                        subtitle: "Coverage and execution across territory",
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _FieldActivityCard(summary: summary),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // 4. Executive Business Overview (Macro Financials)
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

                    // 5. Doctor Response Distribution
                    if (summary != null &&
                        summary.responseDistribution.isNotEmpty) ...[
                      const SectionHeader(
                        title: "Doctor Response Breakdown",
                        subtitle: "Reception from recent field interactions",
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _ResponseDistributionCard(
                        distribution: summary.responseDistribution,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // 6. Promotional Spend by Category
                    if (summary != null &&
                        summary.categoryInvestments.isNotEmpty) ...[
                      const SectionHeader(
                        title: "Promotional Spend by Category",
                        subtitle: "Doctor-specific investment allocation",
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _CategoryInvestmentsCard(
                        investments: summary.categoryInvestments,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // 7. Time Trends (4-Week Progression)
                    if (summary != null && summary.trends.isNotEmpty) ...[
                      const SectionHeader(
                        title: "4-Week Territory Trend",
                        subtitle:
                            "Weekly activity, purchases, and promotional spend",
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _TimeTrendsCard(trends: summary.trends),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // 8. Provenance & Attribution Banner
                    _ProvenanceBanner(
                      onTap: () => _showProvenanceInfo(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 9. Area Performance
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

                    // 10. Doctor Commercial Intelligence & Comparison
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: SectionHeader(
                            title: "Doctor Performance",
                            subtitle:
                                "Top contributing doctors ranked by business value",
                          ),
                        ),
                        InkWell(
                          onTap: () => ref
                              .read(analyticsControllerProvider.notifier)
                              .toggleSort(),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  state.sortByPromoSpend
                                      ? Icons.sort_by_alpha
                                      : Icons.trending_up,
                                  size: 14,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  state.sortByPromoSpend
                                      ? "Sort: Promo Spend"
                                      : "Sort: Business Val",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildDoctorList(context, summary, state.sortByPromoSpend),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDoctorList(
    BuildContext context,
    OverallCommercialSummaryModel? summary,
    bool sortByPromoSpend,
  ) {
    if (summary == null || summary.topDoctors.isEmpty) {
      return const AppCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: Text(
              "No doctor activity recorded for this period.",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final doctors = sortByPromoSpend && summary.highPromoDoctors.isNotEmpty
        ? summary.highPromoDoctors
        : summary.topDoctors;

    return AppCard(
      child: Column(
        children: doctors.asMap().entries.map((entry) {
          final idx = entry.key;
          final doc = entry.value;
          return _DoctorRankRow(
            rank: idx + 1,
            doctor: doc,
            onTap: () => context.push('/doctors/${doc.doctorId}'),
          );
        }).toList(),
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
            const _ProvenanceItem(
              title: "Business Value",
              source: "Realized Purchases",
              desc:
                  "Direct sum of commercial purchases recorded in field sales workflow.",
              color: AppColors.success,
            ),
            const _ProvenanceItem(
              title: "Promotional Investment",
              source: "Explicit Doctor Spend",
              desc:
                  "Attributable cost of samples, promotional units, and free supplies specifically entered.",
              color: AppColors.primaryDark,
            ),
            const _ProvenanceItem(
              title: "Revenue / Margin",
              source: "Revenue unavailable",
              desc:
                  "Pending authoritative price-to-stockist (PTS) formula and Healix product margin tables.",
              color: AppColors.warning,
            ),
            const _ProvenanceItem(
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
                          "Code: ${area.areaCode} • ${area.doctorCount} Doctors • Avg Order: ₹${NumberFormat('#,##,###.00').format(area.avgPurchaseValue)}",
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
                                        const SizedBox(height: 2),
                                        _AttentionSignalsRow(
                                          signals: doc.attentionSignals,
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
                                      Text(
                                        "Promo: ₹${NumberFormat('#,##,###.00').format(doc.promotionalInvestment)}",
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

class _CacheNoticeBanner extends StatelessWidget {
  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  const _CacheNoticeBanner({
    required this.lastUpdated,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = lastUpdated != null
        ? DateFormat('jm').format(lastUpdated!)
        : "recently";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Warm amber tint
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: Color(0xFFF57F17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Showing cached data • Last updated $timeStr",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          InkWell(
            onTap: onRefresh,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                "Refresh",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
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

class _FieldActivityCard extends StatelessWidget {
  final OverallCommercialSummaryModel summary;

  const _FieldActivityCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _ActivityStat(
              icon: Icons.person_pin_outlined,
              label: "Doctors",
              value: "${summary.fieldActivity.totalDoctors}",
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _ActivityStat(
              icon: Icons.directions_walk_outlined,
              label: "Visits",
              value: "${summary.fieldActivity.totalVisits}",
              color: AppColors.primaryDark,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _ActivityStat(
              icon: Icons.shopping_bag_outlined,
              label: "Purchases",
              value: "${summary.fieldActivity.totalPurchases}",
              color: AppColors.success,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _ActivityStat(
              icon: Icons.assignment_late_outlined,
              label: "Follow-ups",
              value: "${summary.fieldActivity.pendingFollowups}",
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ActivityStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
                  subtitle: "Attributable samples & units",
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

class _ResponseDistributionCard extends StatelessWidget {
  final Map<String, int> distribution;

  const _ResponseDistributionCard({required this.distribution});

  Color _getResponseColor(String key) {
    switch (key.toUpperCase()) {
      case 'PRESCRIBING':
        return AppColors.success;
      case 'POSITIVE':
      case 'INTERESTED':
        return const Color(0xFF00897B); // Teal
      case 'NEUTRAL':
        return AppColors.textSecondary;
      case 'HESITANT':
        return AppColors.warning;
      case 'CRITICAL':
        return AppColors.error;
      default:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (sum, val) => sum + val);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: distribution.entries.map((entry) {
              final pct = total > 0 ? (entry.value / total * 100).round() : 0;
              final color = _getResponseColor(entry.key);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${entry.key}: ${entry.value} ($pct%)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryInvestmentsCard extends StatelessWidget {
  final List<CategoryInvestmentItemModel> investments;

  const _CategoryInvestmentsCard({required this.investments});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: investments.map((item) {
          final typeName = item.investmentType.replaceAll('_', ' ');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      typeName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "(${item.count} items)",
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  "₹${NumberFormat('#,##,###.00').format(item.totalAmount)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimeTrendsCard extends StatelessWidget {
  final List<TimeTrendPointModel> trends;

  const _TimeTrendsCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: trends.map((t) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 75,
                  child: Text(
                    t.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "${t.visitsCount} visits",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        "Sales: ₹${NumberFormat('#,##,###').format(t.purchaseAmount)}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        "Promo: ₹${NumberFormat('#,##,###').format(t.promoAmount)}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
                  const SizedBox(height: 2),
                  _AttentionSignalsRow(signals: doctor.attentionSignals),
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

class _AttentionSignalsRow extends StatelessWidget {
  final List<String> signals;

  const _AttentionSignalsRow({required this.signals});

  @override
  Widget build(BuildContext context) {
    if (signals.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: signals.map((s) {
        Color chipBg;
        Color chipText;
        String chipLabel;

        switch (s) {
          case 'NO_PURCHASE_RECENTLY':
            chipBg = const Color(0xFFFFF3E0);
            chipText = const Color(0xFFE65100);
            chipLabel = "No Purchases";
            break;
          case 'HIGH_PROMO_SPEND':
            chipBg = const Color(0xFFFFEBEE);
            chipText = const Color(0xFFC62828);
            chipLabel = "High Promo";
            break;
          case 'TOP_PRESCRIBER':
            chipBg = AppColors.successLight;
            chipText = AppColors.success;
            chipLabel = "Top Prescriber";
            break;
          case 'PENDING_FOLLOWUP':
            chipBg = AppColors.primaryLight;
            chipText = AppColors.primaryDark;
            chipLabel = "Follow-up Due";
            break;
          default:
            chipBg = AppColors.background;
            chipText = AppColors.textSecondary;
            chipLabel = s;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Text(
            chipLabel,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: chipText,
            ),
          ),
        );
      }).toList(),
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
