import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_loading_indicator.dart';
import 'package:rgwin_crm/core/widgets/app_text_field.dart';
import 'package:rgwin_crm/features/doctors/domain/models/doctor_model.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';

class AddEditDoctorScreen extends ConsumerStatefulWidget {
  final String? doctorId;

  const AddEditDoctorScreen({super.key, this.doctorId});

  bool get isEditing => doctorId != null;

  @override
  ConsumerState<AddEditDoctorScreen> createState() =>
      _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends ConsumerState<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _altPhoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _licenseController;
  late final TextEditingController _specializationController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _clinicController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  String? _selectedAreaId;
  String? _selectedAssociationId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _altPhoneController = TextEditingController();
    _emailController = TextEditingController();
    _licenseController = TextEditingController();
    _specializationController = TextEditingController();
    _qualificationController = TextEditingController();
    _clinicController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDoctorDetails();
      });
    }
  }

  Future<void> _loadDoctorDetails() async {
    final state = ref.read(doctorControllerProvider);
    final match = state.doctors.where((d) => d.id == widget.doctorId);
    if (match.isNotEmpty) {
      _populateFromDoctor(match.first);
    }
  }

  void _populateFromDoctor(DoctorModel doc) {
    setState(() {
      _nameController.text = doc.name;
      _phoneController.text = doc.phone;
      _altPhoneController.text = doc.alternatePhone ?? '';
      _emailController.text = doc.email ?? '';
      _licenseController.text = doc.medicalLicenseNumber;
      _specializationController.text = doc.specialization;
      _qualificationController.text = doc.qualification ?? '';
      _clinicController.text = doc.clinicName ?? '';
      _addressController.text = doc.address ?? '';
      _notesController.text = doc.notes ?? '';
      _selectedAreaId = doc.areaId;
      _selectedAssociationId = doc.associationId;
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _clinicController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAreaId == null || _selectedAreaId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a territory area"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final payload = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'alternate_phone': _altPhoneController.text.trim().isNotEmpty
          ? _altPhoneController.text.trim()
          : null,
      'email': _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      'medical_license_number': _licenseController.text.trim().toUpperCase(),
      'specialization': _specializationController.text.trim(),
      'qualification': _qualificationController.text.trim().isNotEmpty
          ? _qualificationController.text.trim()
          : null,
      'clinic_name': _clinicController.text.trim().isNotEmpty
          ? _clinicController.text.trim()
          : null,
      'address': _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      'area_id': _selectedAreaId,
      'association_id': _selectedAssociationId,
      'notes': _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    };

    final controller = ref.read(doctorControllerProvider.notifier);
    final DoctorModel? result;

    if (widget.isEditing) {
      result = await controller.updateDoctor(widget.doctorId!, payload);
    } else {
      result = await controller.createDoctor(payload);
    }

    if (!mounted) return;

    if (result != null) {
      final isOfflineSaved = result.syncState != 'synced';
      final successMsg = isOfflineSaved
          ? "Doctor saved locally! Changes will sync when online."
          : (widget.isEditing
                ? "Doctor updated successfully on server!"
                : "Doctor enrolled successfully on server!");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: isOfflineSaved
              ? AppColors.warning
              : AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorControllerProvider);

    // Auto-select first area if only 1 available (e.g. for MR)
    if (_selectedAreaId == null && state.areas.length == 1) {
      _selectedAreaId = state.areas.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Doctor" : "Add New Doctor"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: widget.isEditing && !_initialized && state.isLoading
          ? const Center(
              child: AppLoadingIndicator(message: "Loading doctor profile..."),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Duplicate Warning Banner
                      if (state.duplicateWarning != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFF87171)),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                                size: 24,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Duplicate Doctor Warning",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      state.duplicateWarning!,
                                      style: const TextStyle(
                                        color: Color(0xFF991B1B),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // General Error Banner
                      if (state.errorMessage != null &&
                          state.duplicateWarning == null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFF87171)),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Section 1: Professional Information
                      const Text(
                        "Professional Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _nameController,
                              label: "Doctor Full Name *",
                              hint: "e.g. Dr. Anitha Ramesh",
                              prefixIcon: Icons.person_outline,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Doctor name is required";
                                }
                                if (v.trim().length < 2) {
                                  return "Name must be at least 2 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _licenseController,
                              label: "Medical License Number *",
                              hint: "e.g. MCI/2015/67890",
                              prefixIcon: Icons.verified_user_outlined,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Medical license number is required";
                                }
                                if (v.trim().length < 3) {
                                  return "License must be at least 3 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    controller: _specializationController,
                                    label: "Specialization *",
                                    hint: "e.g. Cardiology",
                                    prefixIcon: Icons.medical_services_outlined,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return "Specialization is required";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppTextField(
                                    controller: _qualificationController,
                                    label: "Qualifications",
                                    hint: "e.g. MBBS, MD",
                                    prefixIcon: Icons.school_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Section 2: Contact Details
                      const Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _phoneController,
                              label: "Primary Phone Number *",
                              hint: "e.g. +91 98765 43210",
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Phone number is required";
                                }
                                final digits = v.replaceAll(RegExp(r'\D'), '');
                                if (digits.length < 10) {
                                  return "Phone must contain at least 10 digits";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _altPhoneController,
                              label: "Alternate Phone Number",
                              hint: "e.g. 044-24567890",
                              prefixIcon: Icons.phone_in_talk_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _emailController,
                              label: "Email Address",
                              hint: "e.g. doctor@hospital.com",
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty) {
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(v.trim())) {
                                    return "Enter a valid email address";
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Section 3: Clinic & Territory Assignment
                      const Text(
                        "Clinic & Territory Assignment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: _clinicController,
                              label: "Clinic / Hospital Name",
                              hint: "e.g. Apollo Heart Care",
                              prefixIcon: Icons.local_hospital_outlined,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              controller: _addressController,
                              label: "Clinic Address",
                              hint: "e.g. 21 Greams Road, Chennai",
                              prefixIcon: Icons.location_on_outlined,
                              maxLines: 2,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Area Dropdown
                            const Text(
                              "Territory Area *",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedAreaId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.map_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              hint: const Text("Select assigned territory"),
                              items: state.areas.map((a) {
                                return DropdownMenuItem<String>(
                                  value: a.id,
                                  child: Text(
                                    "${a.name} (${a.code})",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedAreaId = val;
                                });
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Please select a territory area";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Association Dropdown
                            const Text(
                              "Medical Association",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedAssociationId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.medical_information_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              hint: const Text(
                                "Select medical association (Optional)",
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("None / Independent"),
                                ),
                                ...state.associations.map((assoc) {
                                  return DropdownMenuItem<String>(
                                    value: assoc.id,
                                    child: Text(
                                      assoc.code != null
                                          ? "${assoc.name} (${assoc.code})"
                                          : assoc.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedAssociationId = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Section 4: Notes
                      const Text(
                        "Notes & Special Instructions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: AppTextField(
                          controller: _notesController,
                          hint:
                              "Field notes, preferred visiting hours, clinical interests...",
                          maxLines: 3,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: "Cancel",
                              variant: AppButtonVariant.outlined,
                              onPressed: () => context.pop(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: widget.isEditing
                                  ? "Save Changes"
                                  : "Enroll Doctor",
                              isLoading: state.isSaving,
                              onPressed: _submitForm,
                            ),
                          ),
                        ],
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
