import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';
import 'package:rgwin_crm/core/widgets/app_loading_indicator.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';
import 'package:rgwin_crm/core/widgets/status_chip.dart';
import 'package:rgwin_crm/features/visits/domain/models/visit_model.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class VisitsShellScreen extends ConsumerWidget {
  const VisitsShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visitControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Log Visit",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () => context.push('/visits/add'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(visitControllerProvider.notifier).loadVisits();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              const Text(
                "Doctor Visits",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Log field interactions, product detailing & doctor response",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: "All Visits",
                      isSelected: state.activeFilter == "ALL",
                      onTap: () => ref
                          .read(visitControllerProvider.notifier)
                          .setFilter("ALL"),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _FilterChip(
                      label: "Today (${state.todayVisits.length})",
                      isSelected: state.activeFilter == "TODAY",
                      onTap: () => ref
                          .read(visitControllerProvider.notifier)
                          .setFilter("TODAY"),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _FilterChip(
                      label: "Upcoming",
                      isSelected: state.activeFilter == "UPCOMING",
                      onTap: () => ref
                          .read(visitControllerProvider.notifier)
                          .setFilter("UPCOMING"),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _FilterChip(
                      label: "Completed",
                      isSelected: state.activeFilter == "COMPLETED",
                      onTap: () => ref
                          .read(visitControllerProvider.notifier)
                          .setFilter("COMPLETED"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Visits List
              if (state.isLoading && state.visits.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: AppLoadingIndicator(message: "Loading visits..."),
                  ),
                )
              else if (state.filteredVisits.isEmpty)
                AppCard(
                  child: AppEmptyState(
                    icon: Icons.assignment_late_outlined,
                    title: "No visits found",
                    description: state.activeFilter == "TODAY"
                        ? "No visits scheduled or recorded for today."
                        : "Start by recording your first doctor field visit.",
                    actionLabel: "Log Doctor Visit",
                    onActionPressed: () => context.push('/visits/add'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.filteredVisits.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final visit = state.filteredVisits[index];
                    return _VisitCard(visit: visit);
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      onTap: onTap,
      scaleDown: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final VisitModel visit;

  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(visit.visitDatetime);
    final dateStr = DateFormat('EEE, d MMM yyyy').format(visit.visitDatetime);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        if (visit.doctorId.isNotEmpty) {
          context.push('/doctors/${visit.doctorId}');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primaryGlow.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 16,
                        color: AppColors.primaryDark,
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.doctorName ?? "Dr. Medical Professional",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visit.clinicName ??
                          visit.specialization ??
                          "General Clinic",
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
                  StatusChip.fromStatus(visit.status),
                  const SizedBox(height: 4),
                  StatusChip(
                    label: visit.doctorResponse,
                    variant:
                        visit.doctorResponse == 'POSITIVE' ||
                            visit.doctorResponse == 'PRESCRIBING'
                        ? StatusChipVariant.success
                        : StatusChipVariant.neutral,
                  ),
                ],
              ),
            ],
          ),
          if (visit.discussedProducts != null ||
              visit.samplesGiven != null) ...[
            const Divider(height: AppSpacing.md),
            Row(
              children: [
                if (visit.discussedProducts != null) ...[
                  const Icon(
                    Icons.medication_outlined,
                    size: 14,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      visit.discussedProducts!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (visit.samplesGiven != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryVeryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Samples: ${visit.samplesGiven}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              if (visit.followUpRequired)
                Row(
                  children: [
                    const Icon(
                      Icons.event_note,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      visit.followUpDate != null
                          ? "Follow-up: ${DateFormat('dd MMM').format(visit.followUpDate!)}"
                          : "Follow-up required",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
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
