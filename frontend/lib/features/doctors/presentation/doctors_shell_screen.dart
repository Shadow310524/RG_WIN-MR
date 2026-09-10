import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';
import 'package:rgwin_crm/core/widgets/app_error_state.dart';
import 'package:rgwin_crm/core/widgets/app_loading_indicator.dart';
import 'package:rgwin_crm/core/widgets/app_text_field.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';
import 'package:rgwin_crm/core/widgets/status_chip.dart';
import 'package:rgwin_crm/features/doctors/domain/models/area_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/association_model.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';

class DoctorsShellScreen extends ConsumerStatefulWidget {
  const DoctorsShellScreen({super.key});

  @override
  ConsumerState<DoctorsShellScreen> createState() => _DoctorsShellScreenState();
}

class _DoctorsShellScreenState extends ConsumerState<DoctorsShellScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context, DoctorState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Doctors",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(doctorControllerProvider.notifier)
                              .setAreaFilter(null);
                          ref
                              .read(doctorControllerProvider.notifier)
                              .setAssociationFilter(null);
                          ref
                              .read(doctorControllerProvider.notifier)
                              .setStatusFilter(null);
                          Navigator.pop(ctx);
                        },
                        child: const Text("Reset All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Area Filter
                  const Text(
                    "Territory Area",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text("All Areas"),
                          selected: state.selectedAreaId == null,
                          onSelected: (_) {
                            ref
                                .read(doctorControllerProvider.notifier)
                                .setAreaFilter(null);
                            Navigator.pop(ctx);
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        ...state.areas.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xs,
                            ),
                            child: ChoiceChip(
                              label: Text(a.name),
                              selected: state.selectedAreaId == a.id,
                              onSelected: (_) {
                                ref
                                    .read(doctorControllerProvider.notifier)
                                    .setAreaFilter(a.id);
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Association Filter
                  const Text(
                    "Medical Association",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text("All Associations"),
                          selected: state.selectedAssociationId == null,
                          onSelected: (_) {
                            ref
                                .read(doctorControllerProvider.notifier)
                                .setAssociationFilter(null);
                            Navigator.pop(ctx);
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        ...state.associations.map(
                          (assoc) => Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xs,
                            ),
                            child: ChoiceChip(
                              label: Text(assoc.code ?? assoc.name),
                              selected: state.selectedAssociationId == assoc.id,
                              onSelected: (_) {
                                ref
                                    .read(doctorControllerProvider.notifier)
                                    .setAssociationFilter(assoc.id);
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Status Filter
                  const Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("All"),
                        selected: state.selectedStatus == null,
                        onSelected: (_) {
                          ref
                              .read(doctorControllerProvider.notifier)
                              .setStatusFilter(null);
                          Navigator.pop(ctx);
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ChoiceChip(
                        label: const Text("Active Only"),
                        selected: state.selectedStatus == 'ACTIVE',
                        onSelected: (_) {
                          ref
                              .read(doctorControllerProvider.notifier)
                              .setStatusFilter('ACTIVE');
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_doctor_fab'),
        onPressed: () => context.push('/doctors/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Doctor"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline Notification Banner
            if (state.isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                color: const Color(0xFFFFFBEB),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        "Offline Mode — Showing cached doctor data",
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    AppButton(
                      label: "Retry",
                      variant: AppButtonVariant.text,
                      height: 32,
                      onPressed: () {
                        ref
                            .read(doctorControllerProvider.notifier)
                            .loadDoctors();
                      },
                    ),
                  ],
                ),
              ),

            // Top Header: Title & Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Doctor Directory",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "${state.total} ${state.total == 1 ? 'doctor' : 'doctors'} enrolled",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.filter_list),
                        tooltip: "Filter Doctors",
                        onPressed: () => _showFilterModal(context, state),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Refresh List",
                        onPressed: () {
                          ref
                              .read(doctorControllerProvider.notifier)
                              .loadInitialData();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppTextField(
                controller: _searchController,
                hint: "Search by Dr. name, phone, license, clinic...",
                prefixIcon: Icons.search,
                suffix: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(doctorControllerProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                onChanged: (val) {
                  ref
                      .read(doctorControllerProvider.notifier)
                      .setSearchQuery(val);
                },
              ),
            ),

            // Active Filter Tags
            if (state.selectedAreaId != null ||
                state.selectedAssociationId != null ||
                state.selectedStatus != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (state.selectedAreaId != null) ...[
                        Chip(
                          label: Text(
                            "Area: ${state.areas.firstWhere(
                              (a) => a.id == state.selectedAreaId,
                              orElse: () => AreaModel(id: '', name: 'Selected Area', code: '', status: '', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
                            ).name}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            ref
                                .read(doctorControllerProvider.notifier)
                                .setAreaFilter(null);
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      if (state.selectedAssociationId != null) ...[
                        Chip(
                          label: Text(
                            "Assoc: ${state.associations.firstWhere(
                              (assoc) => assoc.id == state.selectedAssociationId,
                              orElse: () => AssociationModel(id: '', name: 'Assoc', status: '', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
                            ).name}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            ref
                                .read(doctorControllerProvider.notifier)
                                .setAssociationFilter(null);
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      if (state.selectedStatus != null) ...[
                        Chip(
                          label: Text("Status: ${state.selectedStatus}"),
                          onDeleted: () {
                            ref
                                .read(doctorControllerProvider.notifier)
                                .setStatusFilter(null);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.sm),

            // Body: Content List / Empty / Error / Loading
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading && state.doctors.isEmpty) {
                    return const Center(
                      child: AppLoadingIndicator(message: "Loading doctors..."),
                    );
                  }

                  if (state.errorMessage != null && state.doctors.isEmpty) {
                    return AppErrorState(
                      title: "Failed to load doctors",
                      message: state.errorMessage!,
                      onRetry: () {
                        ref
                            .read(doctorControllerProvider.notifier)
                            .loadInitialData();
                      },
                    );
                  }

                  if (state.doctors.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.person_search_outlined,
                      title: "No doctors found",
                      description: state.searchQuery.isNotEmpty
                          ? "No matching doctor profiles for '${state.searchQuery}'."
                          : "No doctors have been enrolled in your territory yet.",
                      actionLabel: "Add Doctor",
                      onActionPressed: () => context.push('/doctors/add'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(doctorControllerProvider.notifier)
                          .loadDoctors();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        80, // bottom padding for FAB
                      ),
                      itemCount: state.doctors.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final doctor = state.doctors[index];
                        return _DoctorCard(
                          doctor: doctor,
                          onTap: () => context.push('/doctors/${doctor.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final qualAndSpec = [
      if (doctor.qualification != null && doctor.qualification!.isNotEmpty)
        doctor.qualification!,
      doctor.specialization,
    ].join(" • ");

    final initials = doctor.name
        .replaceFirst(RegExp(r'^Dr\.\s*', caseSensitive: false), '')
        .trim();
    final initialChar = initials.isNotEmpty ? initials[0].toUpperCase() : 'D';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Doctor Avatar, Name, Status & Popup Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    initialChar,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (doctor.syncState != 'synced') ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.sync,
                            size: 14,
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      qualAndSpec,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              StatusChip.fromStatus(doctor.isActive ? "ACTIVE" : "INACTIVE"),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                color: AppColors.surface,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "view",
                    child: Text("View Profile"),
                  ),
                  const PopupMenuItem(value: "visit", child: Text("Log Visit")),
                  const PopupMenuItem(
                    value: "purchase",
                    child: Text("Record Purchase"),
                  ),
                  const PopupMenuItem(
                    value: "edit",
                    child: Text("Edit Details"),
                  ),
                ],
                onSelected: (val) {
                  if (val == "view") {
                    context.push('/doctors/${doctor.id}');
                  } else if (val == "visit") {
                    context.push('/visits/add?doctor_id=${doctor.id}');
                  } else if (val == "purchase") {
                    context.push('/sales/record?doctor_id=${doctor.id}');
                  } else if (val == "edit") {
                    context.push('/doctors/${doctor.id}/edit');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Row 2: Clinic & Area Details
          if (doctor.clinicName != null && doctor.clinicName!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    doctor.clinicName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
          ],

          if (doctor.areaName != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  doctor.areaName!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          const Divider(height: AppSpacing.sm, color: AppColors.border),

          // Action Row: Call, Log Visit, View Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SpringButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Calling ${doctor.phone}..."),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                scaleDown: 0.95,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.phone,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  SpringButton(
                    onTap: () =>
                        context.push('/visits/add?doctor_id=${doctor.id}'),
                    scaleDown: 0.95,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryVeryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text(
                        "Log Visit",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SpringButton(
                    onTap: onTap,
                    scaleDown: 0.95,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            "View Profile",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
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
