import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';
import 'package:rgwin_crm/core/widgets/app_loading_indicator.dart';
import 'package:rgwin_crm/core/widgets/metric_card.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/core/widgets/status_chip.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';

class SalesShellScreen extends ConsumerWidget {
  const SalesShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Record Purchase",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () => context.push('/sales/record'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(purchaseControllerProvider.notifier).loadPurchases();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              const Text(
                "Sales & Commercials",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Purchases, realized revenue & stockist commercial tracking",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),

              // KPI Grid (2x2)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.4,
                children: [
                  MetricCard(
                    title: "Total Purchases",
                    value:
                        "₹${NumberFormat('#,##,###').format(state.totalPurchaseAmount)}",
                    icon: Icons.account_balance_wallet_outlined,
                    accentColor: AppColors.primary,
                    subtitle: "${state.purchases.length} recorded entries",
                  ),
                  MetricCard(
                    title: "Realized Revenue",
                    value:
                        "₹${NumberFormat('#,##,###').format(state.totalRevenue)}",
                    icon: Icons.currency_rupee,
                    accentColor: AppColors.success,
                    subtitle: "Commercial value",
                  ),
                  const MetricCard(
                    title: "PTS Value",
                    value: "—",
                    icon: Icons.price_check_outlined,
                    accentColor: AppColors.warning,
                    subtitle: "Formula pending",
                  ),
                  const MetricCard(
                    title: "Net Profit / Loss",
                    value: "—",
                    icon: Icons.analytics_outlined,
                    accentColor: AppColors.textMuted,
                    isUnavailable: true,
                    subtitle: "Insufficient cost data",
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // PTS Notice
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        "PTS rate and profit metrics will be automatically computed once the official Healix business formula is finalized.",
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
              const SizedBox(height: AppSpacing.xl),

              // Purchases History
              SectionHeader(
                title: "Recent Purchases",
                subtitle: "Overall commercial transactions",
                actionLabel: state.purchases.isNotEmpty ? "Record New" : null,
                onAction: () => context.push('/sales/record'),
              ),
              const SizedBox(height: AppSpacing.sm),

              if (state.isLoading && state.purchases.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: AppLoadingIndicator(message: "Loading purchases..."),
                  ),
                )
              else if (state.purchases.isEmpty)
                AppCard(
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: "No purchases recorded yet",
                    description:
                        "Record overall purchase amounts from doctors or medical stores without entering line-by-line items.",
                    actionLabel: "Record First Purchase",
                    onActionPressed: () => context.push('/sales/record'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.purchases.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = state.purchases[index];
                    return AppCard(
                      onTap: () {
                        if (item.doctorId != null &&
                            item.doctorId!.isNotEmpty) {
                          context.push('/doctors/${item.doctorId}');
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(item.purchaseDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              StatusChip.fromStatus(item.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.doctorName ??
                                (item.clinicName ?? "Direct Medicals"),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Divider(
                            height: AppSpacing.md,
                            color: AppColors.border,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Purchase: ₹${NumberFormat('#,##,###.00').format(item.purchaseAmount)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    "GST: ₹${NumberFormat('#,##,###.00').format(item.gstAmount)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Total: ₹${NumberFormat('#,##,###.00').format(item.totalAmount)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    "PTS: Not configured",
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
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
    );
  }
}
