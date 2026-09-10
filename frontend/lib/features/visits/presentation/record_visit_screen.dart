import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_text_field.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';
import 'package:rgwin_crm/features/followups/presentation/follow_up_controller.dart';
import 'package:rgwin_crm/features/visits/presentation/visit_controller.dart';

class RecordVisitScreen extends ConsumerStatefulWidget {
  final String? preselectedDoctorId;

  const RecordVisitScreen({super.key, this.preselectedDoctorId});

  @override
  ConsumerState<RecordVisitScreen> createState() => _RecordVisitScreenState();
}

class _RecordVisitScreenState extends ConsumerState<RecordVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedDoctorId;
  String? _selectedDoctorName;
  String? _selectedClinicName;
  String? _selectedSpecialization;

  DateTime _visitDateTime = DateTime.now();
  String _doctorResponse = "POSITIVE";
  bool _purchaseOpportunity = false;
  bool _followUpRequired = false;
  DateTime? _followUpDate;

  final TextEditingController _discussedController = TextEditingController();
  final TextEditingController _samplesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _followUpTaskController = TextEditingController();

  final List<Map<String, String>> _responseOptions = [
    {
      'value': 'POSITIVE',
      'label': 'Positive',
      'desc': 'Interested in product range',
    },
    {
      'value': 'PRESCRIBING',
      'label': 'Prescribing',
      'desc': 'Already writing prescriptions',
    },
    {
      'value': 'NEUTRAL',
      'label': 'Neutral',
      'desc': 'Needs more clinical samples/data',
    },
    {
      'value': 'HESITANT',
      'label': 'Hesitant',
      'desc': 'Loyal to competing brands',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDoctorId = widget.preselectedDoctorId;
  }

  @override
  void dispose() {
    _discussedController.dispose();
    _samplesController.dispose();
    _notesController.dispose();
    _followUpTaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _visitDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_visitDateTime),
      );
      if (time != null) {
        setState(() {
          _visitDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _followUpDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a doctor to record this visit."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(visitControllerProvider.notifier)
        .recordVisit(
          doctorId: _selectedDoctorId!,
          doctorName: _selectedDoctorName,
          clinicName: _selectedClinicName,
          specialization: _selectedSpecialization,
          visitDatetime: _visitDateTime,
          doctorResponse: _doctorResponse,
          discussedProducts: _discussedController.text.trim().isEmpty
              ? null
              : _discussedController.text.trim(),
          samplesGiven: _samplesController.text.trim().isEmpty
              ? null
              : _samplesController.text.trim(),
          purchaseOpportunity: _purchaseOpportunity,
          followUpRequired: _followUpRequired,
          followUpDate: _followUpDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (_followUpRequired && _followUpDate != null) {
      final taskReason = _followUpTaskController.text.trim().isNotEmpty
          ? _followUpTaskController.text.trim()
          : "Follow up on prescription and product discussions";
      await ref
          .read(followUpControllerProvider.notifier)
          .createFollowUp(
            doctorId: _selectedDoctorId!,
            doctorName: _selectedDoctorName,
            clinicName: _selectedClinicName,
            dueDate: _followUpDate!,
            taskReason: taskReason,
          );
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Visit recorded"),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorControllerProvider);
    final isSaving = ref.watch(visitControllerProvider).isLoading;

    // Resolve preselected doctor details
    if (_selectedDoctorId != null && _selectedDoctorName == null) {
      final doc = doctorState.doctors
          .where((d) => d.id == _selectedDoctorId)
          .firstOrNull;
      if (doc != null) {
        _selectedDoctorName = doc.name;
        _selectedClinicName = doc.clinicName;
        _selectedSpecialization = doc.specialization;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Log Doctor Visit"),
        backgroundColor: AppColors.background,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Doctor Selection Card
                const SectionHeader(
                  title: "Doctor & Clinic",
                  subtitle: "Select the doctor you are detailing to",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: AppColors.surface,
                    value: _selectedDoctorId,
                    decoration: const InputDecoration(
                      labelText: "Select Doctor",
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    items: doctorState.doctors.map((d) {
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text(
                          "${d.name} (${d.clinicName ?? d.specialization})",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDoctorId = val;
                        final doc = doctorState.doctors
                            .where((d) => d.id == val)
                            .firstOrNull;
                        _selectedDoctorName = doc?.name;
                        _selectedClinicName = doc?.clinicName;
                        _selectedSpecialization = doc?.specialization;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Date & Time
                const SectionHeader(title: "Visit Schedule & Time"),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      "Visit Date & Time",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'EEE, dd MMM yyyy • hh:mm a',
                      ).format(_visitDateTime),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.edit_calendar_outlined,
                      size: 20,
                    ),
                    onTap: _pickDateTime,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Discussion & What was given
                const SectionHeader(
                  title: "Discussion & Activity",
                  subtitle: "Topics detailed and samples distributed",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _discussedController,
                        label: "What was discussed / activity",
                        hint: "e.g. Detailed comparative clinical trials",
                        prefixIcon: Icons.medical_information_outlined,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _samplesController,
                        label: "What was given / samples handed over",
                        hint: "e.g. 5 sample strips, 1 product monograph",
                        prefixIcon: Icons.inventory_2_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Doctor Response
                const SectionHeader(
                  title: "Doctor's Response",
                  subtitle: "Level of commitment and reception",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: _responseOptions.map((opt) {
                      final isSelected = _doctorResponse == opt['value'];
                      return InkWell(
                        onTap: () =>
                            setState(() => _doctorResponse = opt['value']!),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt['label']!,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      opt['desc']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 5. Commercial Opportunity & Follow-up
                const SectionHeader(title: "Follow-up & Opportunity"),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primaryDark,
                        title: const Text(
                          "Immediate Purchase Opportunity?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          "Doctor expressed intent to order through stockist",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        value: _purchaseOpportunity,
                        onChanged: (val) =>
                            setState(() => _purchaseOpportunity = val),
                      ),
                      if (_purchaseOpportunity) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.successLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Commercial purchase opportunity expressed.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppButton(
                                label: "Record Purchase",
                                icon: Icons.receipt_long_outlined,
                                variant: AppButtonVariant.outlined,
                                onPressed: () {
                                  context.push(
                                    '/sales/record${_selectedDoctorId != null ? '?doctor_id=$_selectedDoctorId' : ''}',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primaryDark,
                        title: const Text(
                          "Follow-up Required?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          "Schedule a reminder for next interaction",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        value: _followUpRequired,
                        onChanged: (val) {
                          setState(() {
                            _followUpRequired = val;
                            if (val && _followUpDate == null) {
                              _followUpDate = DateTime.now().add(
                                const Duration(days: 7),
                              );
                            }
                          });
                        },
                      ),
                      if (_followUpRequired) ...[
                        const SizedBox(height: AppSpacing.sm),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          tileColor: AppColors.primaryVeryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          leading: const Icon(
                            Icons.event,
                            color: AppColors.primaryDark,
                          ),
                          title: const Text(
                            "Next Follow-up Date",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            _followUpDate != null
                                ? DateFormat(
                                    'EEE, dd MMM yyyy',
                                  ).format(_followUpDate!)
                                : "Select date",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                          ),
                          onTap: _pickFollowUpDate,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          controller: _followUpTaskController,
                          label: "Follow-up Task",
                          hint: "e.g. Call regarding purchase requirement",
                          prefixIcon: Icons.task_alt_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 6. Notes
                const SectionHeader(title: "Additional Notes"),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: AppTextField(
                    controller: _notesController,
                    label: "Observations / Feedback",
                    hint:
                        "e.g. Prefers visits after 6 PM, interested in pediatric syrups",
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save Button
                AppButton(
                  label: "Save Visit",
                  icon: Icons.check,
                  isLoading: isSaving,
                  fullWidth: true,
                  onPressed: isSaving ? null : _handleSubmit,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
