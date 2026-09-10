import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_badge.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_loading_indicator.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Doctor Profile"),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit Doctor",
            onPressed: () => context.go('/doctors/$doctorId/edit'),
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
                            onPressed: () => context.go(
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
                            onPressed: () => context.go(
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

              // 4. Commercial & Purchase Summary
              const SectionHeader(
                title: "Purchase & Commercial Summary",
                subtitle: "Authoritative business performance",
              ),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Column(
                  children: const [
                    _DetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: "Total Purchases Booked",
                      value: "Tracked from sales purchases",
                    ),
                    _DetailRow(
                      icon: Icons.currency_rupee,
                      label: "Realized Revenue",
                      value: "Gross realized total",
                    ),
                    _DetailRow(
                      icon: Icons.price_check_outlined,
                      label: "PTS Formula Rate",
                      value: "Not configured",
                    ),
                    _DetailRow(
                      icon: Icons.pie_chart_outline,
                      label: "PTS Value",
                      value: "—",
                    ),
                    _DetailRow(
                      icon: Icons.analytics_outlined,
                      label: "Net Profit / Loss",
                      value: "Insufficient data",
                    ),
                  ],
                ),
              ),

              // 5. Field Notes (if available)
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

              // 6. Recent Visits & Activity Hub
              AppCard(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Visits & Product Interactions",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Coming in Phase 4 — Field visits, discussed products, sample distributions, and prescription tracking.",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Edit Button
              AppButton(
                label: "Edit Doctor Details",
                icon: Icons.edit,
                fullWidth: true,
                onPressed: () => context.go('/doctors/$doctorId/edit'),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
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
