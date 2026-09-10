import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_badge.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_loading_indicator.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';
import 'package:rgwin_crm/core/widgets/status_chip.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/followups/presentation/follow_up_controller.dart';
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';
import 'package:rgwin_crm/features/promotions/presentation/promotional_investment_controller.dart';
import 'package:rgwin_crm/features/promotions/presentation/record_promotional_investment_dialog.dart';

class DoctorDetailScreen extends ConsumerWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(doctorControllerProvider);
    final match = state.doctors.where((d) => d.id == doctorId);

    if (match.isEmpty) {
      if (state.isLoading) {
        return const Scaffold(
          body: Center(
            child: AppLoadingIndicator(message: "Loading doctor profile..."),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text("Doctor Details")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                "Doctor profile not found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: "Back to Directory",
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      );
    }

    final doctor = match.first;

    final visitState = ref.watch(visitControllerProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);
    final followUpState = ref.watch(followUpControllerProvider);
    final investmentState = ref.watch(promotionalInvestmentControllerProvider);

    final doctorVisits = visitState.visits
        .where((v) => v.doctorId == doctorId)
        .toList();
    final doctorPurchases = purchaseState.purchases
        .where((p) => p.doctorId == doctorId)
        .toList();
    final doctorFollowUps = followUpState.followUps
        .where((f) => f.doctorId == doctorId)
        .toList();
    final doctorInvestments = investmentState.investments
        .where((i) => i.doctorId == doctorId)
        .toList();
    final pendingFollowUps = doctorFollowUps
        .where((f) => f.status == "PENDING")
        .toList();

    final totalPurchaseVal = doctorPurchases.fold(
      0.0,
      (sum, p) => sum + p.purchaseAmount,
    );
    final totalInvestVal = doctorInvestments.fold(
      0.0,
      (sum, i) => sum + i.amount,
    );
    final latestPurchase = doctorPurchases.isNotEmpty
        ? doctorPurchases.first
        : null;

    final List<_TimelineItem> timelineItems = [];
    for (final v in doctorVisits) {
      timelineItems.add(
        _TimelineItem(
          date: v.visitDatetime,
          typeTitle: "Visit",
          mainText: v.discussedProducts ?? "Field detailing visit",
          subText:
              "Doctor response: ${v.doctorResponse}${v.samplesGiven != null ? ' • Samples: ${v.samplesGiven}' : ''}",
          icon: Icons.assignment_outlined,
          badgeColor: AppColors.primaryDark,
        ),
      );
    }
    for (final p in doctorPurchases) {
      timelineItems.add(
        _TimelineItem(
          date: p.purchaseDate,
          typeTitle: "Purchase",
          mainText:
              "₹${NumberFormat('#,##,###.00').format(p.purchaseAmount)} + GST",
          subText:
              "Total: ₹${NumberFormat('#,##,###.00').format(p.totalAmount)} • PTS: Not configured",
          icon: Icons.receipt_long_outlined,
          badgeColor: AppColors.success,
        ),
      );
    }
    for (final inv in doctorInvestments) {
      timelineItems.add(
        _TimelineItem(
          date: inv.investmentDate,
          typeTitle: "Promotional (${inv.typeDisplay})",
          mainText: "₹${NumberFormat('#,##,###.00').format(inv.amount)}",
          subText: inv.visitId != null
              ? "Linked to Visit • ${inv.notes ?? 'Attributable promotional spend'}"
              : (inv.notes ?? "Doctor promotional investment"),
          icon: Icons.inventory_2_outlined,
          badgeColor: AppColors.primary,
        ),
      );
    }
    for (final f in doctorFollowUps) {
      timelineItems.add(
        _TimelineItem(
          date: f.dueDate,
          typeTitle: "Follow-up (${f.status})",
          mainText: f.taskReason,
          subText: f.isCompleted ? "Completed" : "Scheduled commitment",
          icon: Icons.event_note_outlined,
          badgeColor: f.isCompleted
              ? AppColors.textSecondary
              : AppColors.secondary,
        ),
      );
    }
    timelineItems.sort((a, b) => b.date.compareTo(a.date));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/doctors');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Doctor Profile"),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: "Back to Doctors",
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/doctors');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Edit Doctor",
              onPressed: () => context.push('/doctors/$doctorId/edit'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Central Relationship Hub Header Card
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              doctor.name.isNotEmpty
                                  ? doctor.name
                                        .replaceAll('Dr. ', '')
                                        .trim()
                                        .substring(0, 1)
                                        .toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (doctor.qualification != null &&
                                    doctor.qualification!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    doctor.qualification!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                AppBadge(
                                  label: doctor.specialization,
                                  variant: AppBadgeVariant.info,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppBadge(
                                label: doctor.isActive ? "ACTIVE" : "INACTIVE",
                                variant: doctor.isActive
                                    ? AppBadgeVariant.active
                                    : AppBadgeVariant.inactive,
                              ),
                              if (doctor.syncState != 'synced') ...[
                                const SizedBox(height: 4),
                                const AppBadge(
                                  label: "Pending Sync",
                                  variant: AppBadgeVariant.pending,
                                  icon: Icons.sync,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const Divider(height: AppSpacing.xl),

                      // Primary Actions: [ Call ] [ Log Visit ] [ Purchase ]
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: "Call",
                              icon: Icons.phone_outlined,
                              variant: AppButtonVariant.outlined,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Calling ${doctor.phone}..."),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton(
                              label: "Visit",
                              icon: Icons.assignment_outlined,
                              variant: AppButtonVariant.outlined,
                              onPressed: () => context.push(
                                '/visits/add?doctor_id=${doctor.id}',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton(
                              label: "Purchase",
                              icon: Icons.receipt_long_outlined,
                              variant: AppButtonVariant.outlined,
                              onPressed: () => context.push(
                                '/sales/record?doctor_id=${doctor.id}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 2. Contact & Clinic Details Card
                const SectionHeader(
                  title: "Contact & Clinic",
                  subtitle: "Location and direct touchpoints",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: "Primary Phone",
                        value: doctor.phone,
                      ),
                      if (doctor.alternatePhone != null &&
                          doctor.alternatePhone!.isNotEmpty)
                        _DetailRow(
                          icon: Icons.phone_in_talk_outlined,
                          label: "Alternate Phone",
                          value: doctor.alternatePhone!,
                        ),
                      if (doctor.email != null && doctor.email!.isNotEmpty)
                        _DetailRow(
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: doctor.email!,
                        ),
                      if (doctor.clinicName != null &&
                          doctor.clinicName!.isNotEmpty)
                        _DetailRow(
                          icon: Icons.local_hospital_outlined,
                          label: "Clinic / Medical Facility",
                          value: doctor.clinicName!,
                        ),
                      if (doctor.address != null && doctor.address!.isNotEmpty)
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: "Address",
                          value: doctor.address!,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 3. Territory & Medical Affiliations
                const SectionHeader(
                  title: "Territory & Credentials",
                  subtitle: "Regulatory and association assignments",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.verified_user_outlined,
                        label: "Medical License",
                        value: doctor.medicalLicenseNumber,
                      ),
                      _DetailRow(
                        icon: Icons.map_outlined,
                        label: "Territory Area",
                        value: doctor.areaName ?? "Assigned Area",
                      ),
                      if (doctor.associationName != null)
                        _DetailRow(
                          icon: Icons.medical_services_outlined,
                          label: "Medical Association",
                          value: doctor.associationName!,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 4. Commercial & Profitability Overview
                SectionHeader(
                  title: "Purchase & Commercial Summary",
                  subtitle:
                      "Commercial Worth: Business Value vs Promotional Spend",
                  actionLabel: "Record Purchase",
                  onAction: () =>
                      context.push('/sales/record?doctor_id=${doctor.id}'),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Business Value (Purchases)",
                        value: doctorPurchases.isEmpty
                            ? "No purchases recorded"
                            : "₹${NumberFormat('#,##,###.00').format(totalPurchaseVal)}",
                      ),
                      _DetailRow(
                        icon: Icons.inventory_2_outlined,
                        label: "Promotional Investment",
                        value: doctorInvestments.isEmpty
                            ? "No promotional spend"
                            : "₹${NumberFormat('#,##,###.00').format(totalInvestVal)}",
                      ),
                      if (latestPurchase != null)
                        _DetailRow(
                          icon: Icons.shopping_bag_outlined,
                          label: "Latest Purchase",
                          value:
                              "₹${NumberFormat('#,##,###.00').format(latestPurchase.purchaseAmount)} • ${DateFormat('dd MMM yyyy').format(latestPurchase.purchaseDate)}",
                        ),
                      const _DetailRow(
                        icon: Icons.currency_rupee,
                        label: "Realized Revenue",
                        value: "Revenue unavailable",
                      ),
                      const _DetailRow(
                        icon: Icons.price_check_outlined,
                        label: "PTS Formula Rate",
                        value: "Not configured",
                      ),
                      const _DetailRow(
                        icon: Icons.pie_chart_outline,
                        label: "PTS Value",
                        value: "—",
                      ),
                      const _DetailRow(
                        icon: Icons.analytics_outlined,
                        label: "Doctor Commercial Result",
                        value: "Insufficient data",
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                "Provenance: General field expenses (fuel, food, travel) are kept separate and not deducted from doctor commercial worth.",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 4b. Promotional Investment History
                SectionHeader(
                  title: "Promotional Investment History",
                  subtitle:
                      "Direct promotional spend attributable to this doctor",
                  actionLabel: "+ Record",
                  onAction: () => showRecordPromotionalInvestmentSheet(
                    context,
                    doctorId: doctor.id,
                    doctorName: doctor.name,
                    clinicName: doctor.clinicName,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (doctorInvestments.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 28,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            const Text(
                              "No promotional investments recorded yet.",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  AppCard(
                    child: Column(
                      children: doctorInvestments.take(5).map((inv) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.receipt_outlined,
                                  size: 16,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          inv.typeDisplay,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (inv.visitId != null) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.pill,
                                                  ),
                                            ),
                                            child: const Text(
                                              "Linked to Visit",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      DateFormat(
                                            'd MMM yyyy',
                                          ).format(inv.investmentDate) +
                                          (inv.notes != null
                                              ? ' • ${inv.notes}'
                                              : ''),
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
                              Text(
                                "₹${NumberFormat('#,##,###.00').format(inv.amount)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // 5. Upcoming Follow-ups for this doctor
                SectionHeader(
                  title: "Upcoming Follow-ups",
                  subtitle: "Scheduled commitments and tasks",
                  actionLabel: "View all",
                  onAction: () => context.push('/followups'),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (pendingFollowUps.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_available_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Expanded(
                            child: Text(
                              "No pending follow-ups for this doctor.",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(
                              '/visits/add?doctor_id=${doctor.id}',
                            ),
                            child: const Text("Schedule"),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingFollowUps.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final fu = pendingFollowUps[index];
                      return AppCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                DateFormat('dd MMM').format(fu.dueDate),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fu.taskReason,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SpringButton(
                              onTap: () {
                                ref
                                    .read(followUpControllerProvider.notifier)
                                    .toggleStatus(fu.id);
                              },
                              scaleDown: 0.9,
                              child: StatusChip.fromStatus("PENDING"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // 6. Field Notes (if available)
                if (doctor.notes != null && doctor.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  const SectionHeader(
                    title: "Field Notes",
                    subtitle: "Observations and relationship history",
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppCard(
                    child: Text(
                      doctor.notes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // 7. Chronological Relationship Activity Timeline
                const SectionHeader(
                  title: "Relationship Activity Timeline",
                  subtitle: "Visits, purchases, and follow-ups in order",
                ),
                const SizedBox(height: AppSpacing.xs),
                if (timelineItems.isEmpty)
                  const AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: Text(
                          "No field activity recorded yet. Start by logging a visit or purchase.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  AppCard(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: timelineItems.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: AppSpacing.lg,
                        color: AppColors.border,
                      ),
                      itemBuilder: (context, index) {
                        final item = timelineItems[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item.badgeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                size: 18,
                                color: item.badgeColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.typeTitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: item.badgeColor,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd MMM yyyy',
                                        ).format(item.date),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.mainText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (item.subText != null &&
                                      item.subText!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subText!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Edit Button
                AppButton(
                  label: "Edit Doctor Details",
                  icon: Icons.edit,
                  fullWidth: true,
                  onPressed: () => context.push('/doctors/$doctorId/edit'),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
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

class _TimelineItem {
  final DateTime date;
  final String typeTitle;
  final String mainText;
  final String? subText;
  final IconData icon;
  final Color badgeColor;

  const _TimelineItem({
    required this.date,
    required this.typeTitle,
    required this.mainText,
    this.subText,
    required this.icon,
    required this.badgeColor,
  });
}
