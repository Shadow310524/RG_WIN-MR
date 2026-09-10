import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/metric_card.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseControllerProvider);
    final doctorState = ref.watch(doctorControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Commercial Analytics"),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryDark,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: "Overall"),
            Tab(text: "By Doctor"),
            Tab(text: "By Area"),
            Tab(text: "By MR"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overall View
          _OverallAnalyticsTab(purchaseState: purchaseState),

          // 2. By Doctor View
          _ByDoctorAnalyticsTab(
            purchaseState: purchaseState,
            doctorState: doctorState,
          ),

          // 3. By Area View
          _ByAreaAnalyticsTab(
            purchaseState: purchaseState,
            doctorState: doctorState,
          ),

          // 4. By MR View
          const _ByMrAnalyticsTab(),
        ],
      ),
    );
  }
}

class _OverallAnalyticsTab extends StatelessWidget {
  final PurchaseState purchaseState;

  const _OverallAnalyticsTab({required this.purchaseState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Commercial Performance Summary",
            subtitle: "Total sales, revenue realization & margin indicators",
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.35,
            children: [
              MetricCard(
                title: "Total Purchases",
                value:
                    "₹${NumberFormat('#,##,###').format(purchaseState.totalPurchaseAmount)}",
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.primaryDark,
              ),
              MetricCard(
                title: "Realized Revenue",
                value:
                    "₹${NumberFormat('#,##,###').format(purchaseState.totalRevenue)}",
                icon: Icons.currency_rupee,
                accentColor: AppColors.success,
              ),
              const MetricCard(
                title: "Field Expenses",
                value: "—",
                icon: Icons.receipt_outlined,
                accentColor: AppColors.warning,
                subtitle: "Calculated from claims",
              ),
              const MetricCard(
                title: "Authoritative Profit/Loss",
                value: "—",
                icon: Icons.query_stats,
                accentColor: AppColors.textMuted,
                isUnavailable: true,
                subtitle: "Insufficient cost/revenue data",
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Business Insights Card
          const SectionHeader(title: "Authoritative Business Rule Notice"),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: Row(
              children: const [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    "RG WIN enforces zero false reporting: financial metrics are never estimated as ₹0 when cost data is pending. Realized margin appears upon complete COGS & PTS data.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
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

class _ByDoctorAnalyticsTab extends StatelessWidget {
  final PurchaseState purchaseState;
  final DoctorState doctorState;

  const _ByDoctorAnalyticsTab({
    required this.purchaseState,
    required this.doctorState,
  });

  @override
  Widget build(BuildContext context) {
    if (doctorState.doctors.isEmpty) {
      return const Center(child: Text("No doctors enrolled in territory."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: doctorState.doctors.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final doc = doctorState.doctors[index];
        final docPurchases = purchaseState.purchases
            .where((p) => p.doctorId == doc.id)
            .toList();
        final docTotal = docPurchases.fold(
          0.0,
          (sum, p) => sum + p.totalAmount,
        );

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doc.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    docTotal > 0
                        ? "₹${NumberFormat('#,##,###').format(docTotal)}"
                        : "No purchases",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: docTotal > 0
                          ? AppColors.primaryDark
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "${doc.clinicName ?? 'Clinic'} • ${doc.areaName ?? 'Area'}",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "PTS & P&L Status",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    "Profit/Loss unavailable",
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ByAreaAnalyticsTab extends StatelessWidget {
  final PurchaseState purchaseState;
  final DoctorState doctorState;

  const _ByAreaAnalyticsTab({
    required this.purchaseState,
    required this.doctorState,
  });

  @override
  Widget build(BuildContext context) {
    if (doctorState.areas.isEmpty) {
      return const Center(child: Text("No territory areas assigned."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: doctorState.areas.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final area = doctorState.areas[index];
        final areaDoctors = doctorState.doctors
            .where((d) => d.areaId == area.id)
            .map((d) => d.id)
            .toSet();
        final areaPurchases = purchaseState.purchases
            .where(
              (p) => p.doctorId != null && areaDoctors.contains(p.doctorId!),
            )
            .toList();
        final areaTotal = areaPurchases.fold(
          0.0,
          (sum, p) => sum + p.totalAmount,
        );

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    area.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "₹${NumberFormat('#,##,###').format(areaTotal)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "Territory Code: ${area.code} • ${areaDoctors.length} Doctors",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Area P&L",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    "Profit/Loss unavailable",
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ByMrAnalyticsTab extends StatelessWidget {
  const _ByMrAnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AppCard(
        child: Column(
          children: const [
            Icon(Icons.badge_outlined, size: 36, color: AppColors.primaryDark),
            SizedBox(height: AppSpacing.md),
            Text(
              "Territory Representative Breakdown",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              "MR territory performance is isolated by assigned medical areas. Admin users have cross-representative visibility.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
