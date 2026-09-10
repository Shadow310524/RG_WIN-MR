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
import 'package:rgwin_crm/features/followups/presentation/follow_up_controller.dart';
import 'package:rgwin_crm/features/followups/domain/models/follow_up_model.dart';

class FollowupsShellScreen extends ConsumerStatefulWidget {
  const FollowupsShellScreen({super.key});

  @override
  ConsumerState<FollowupsShellScreen> createState() =>
      _FollowupsShellScreenState();
}

class _FollowupsShellScreenState extends ConsumerState<FollowupsShellScreen> {
  final List<String> _tabs = ["All", "Pending", "Completed"];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followUpControllerProvider);
    final followUps = state.filteredFollowUps;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/more');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Follow-up Tasks"),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: "Back",
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/more');
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Filter Pills Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: _tabs.map((tab) {
                      final key = tab.toUpperCase();
                      final isSelected = state.activeFilter == key;
                      final count = tab == "All"
                          ? state.followUps.length
                          : (tab == "Pending"
                                ? state.pendingFollowUps.length
                                : state.completedFollowUps.length);

                      return Expanded(
                        child: SpringButton(
                          onTap: () {
                            ref
                                .read(followUpControllerProvider.notifier)
                                .setFilter(key);
                          },
                          scaleDown: 0.95,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tab,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "$count",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Content List
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    await ref
                        .read(followUpControllerProvider.notifier)
                        .loadFollowUps();
                  },
                  child: state.isLoading && state.followUps.isEmpty
                      ? const Center(
                          child: AppLoadingIndicator(
                            message: "Loading follow-up tasks...",
                          ),
                        )
                      : followUps.isEmpty
                      ? ListView(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(AppSpacing.xxl),
                              child: AppEmptyState(
                                icon: Icons.event_available_outlined,
                                title: "No follow-ups found",
                                description:
                                    "Schedule follow-ups during doctor visits to stay on top of field commitments.",
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: followUps.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = followUps[index];
                            return _FollowUpCard(item: item);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpCard extends ConsumerWidget {
  final FollowUpModel item;

  const _FollowUpCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = item.isCompleted;
    final dateFormatted = DateFormat('dd MMM yyyy').format(item.dueDate);

    return AppCard(
      onTap: () {
        if (item.doctorId.isNotEmpty) {
          context.push('/doctors/${item.doctorId}');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.successLight
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_circle_outline
                          : Icons.event_note_outlined,
                      size: 16,
                      color: isDone ? AppColors.success : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    dateFormatted,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDone
                          ? AppColors.textSecondary
                          : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              SpringButton(
                onTap: () {
                  ref
                      .read(followUpControllerProvider.notifier)
                      .toggleStatus(item.id);
                },
                scaleDown: 0.9,
                child: StatusChip.fromStatus(item.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.doctorName ?? "Doctor Interaction",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          if (item.clinicName != null && item.clinicName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.clinicName!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 14,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    item.taskReason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.syncStatus == "SYNCED" ? "✓ Synced" : "Pending sync",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: item.syncStatus == "SYNCED"
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(
                  isDone ? Icons.undo : Icons.check_circle,
                  size: 14,
                  color: isDone ? AppColors.textMuted : AppColors.success,
                ),
                label: Text(
                  isDone ? "Mark Pending" : "Mark Completed",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.textMuted : AppColors.success,
                  ),
                ),
                onPressed: () {
                  ref
                      .read(followUpControllerProvider.notifier)
                      .toggleStatus(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
