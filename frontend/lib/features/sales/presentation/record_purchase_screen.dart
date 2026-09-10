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
import 'package:rgwin_crm/features/sales/presentation/purchase_controller.dart';

class RecordPurchaseScreen extends ConsumerStatefulWidget {
  final String? preselectedDoctorId;

  const RecordPurchaseScreen({super.key, this.preselectedDoctorId});

  @override
  ConsumerState<RecordPurchaseScreen> createState() =>
      _RecordPurchaseScreenState();
}

class _RecordPurchaseScreenState extends ConsumerState<RecordPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedDoctorId;
  String? _selectedDoctorName;
  String? _selectedClinicName;
  DateTime _purchaseDate = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double _totalAmount = 0.0;
  bool _customGst = false;

  @override
  void initState() {
    super.initState();
    _selectedDoctorId = widget.preselectedDoctorId;

    _amountController.addListener(_recalculateTotal);
    _gstController.addListener(_recalculateTotal);
  }

  @override
  void dispose() {
    _amountController.removeListener(_recalculateTotal);
    _gstController.removeListener(_recalculateTotal);
    _amountController.dispose();
    _gstController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalculateTotal() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (!_customGst && amount > 0) {
      // Default standard 18% GST estimate for convenience
      final calculatedGst = (amount * 0.18).roundToDouble();
      final newGst = calculatedGst.toStringAsFixed(0);
      if (_gstController.text != newGst) {
        _gstController.text = newGst;
      }
    }

    final gst = double.tryParse(_gstController.text.trim()) ?? 0.0;
    setState(() {
      _totalAmount = amount + gst;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final gst = double.tryParse(_gstController.text.trim()) ?? 0.0;

    final success = await ref
        .read(purchaseControllerProvider.notifier)
        .recordPurchase(
          doctorId: _selectedDoctorId,
          doctorName: _selectedDoctorName,
          clinicName: _selectedClinicName,
          purchaseDate: _purchaseDate,
          purchaseAmount: amount,
          gstAmount: gst,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Purchase recorded successfully."),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorControllerProvider);
    final isSaving = ref.watch(purchaseControllerProvider).isLoading;

    // Resolve preselected doctor details if needed
    if (_selectedDoctorId != null && _selectedDoctorName == null) {
      final doc = doctorState.doctors
          .where((d) => d.id == _selectedDoctorId)
          .firstOrNull;
      if (doc != null) {
        _selectedDoctorName = doc.name;
        _selectedClinicName = doc.clinicName;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Record Purchase"), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Doctor / Medical Entity
                const SectionHeader(
                  title: "Doctor / Medical",
                  subtitle: "Select the purchaser or medical store",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDoctorId,
                    decoration: const InputDecoration(
                      labelText: "Doctor / Clinic",
                      prefixIcon: Icon(Icons.local_hospital_outlined, size: 20),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("Direct / General Medical Store"),
                      ),
                      ...doctorState.doctors.map(
                        (d) => DropdownMenuItem<String>(
                          value: d.id,
                          child: Text(
                            "${d.name} (${d.clinicName ?? d.specialization})",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedDoctorId = val;
                        final doc = doctorState.doctors
                            .where((d) => d.id == val)
                            .firstOrNull;
                        _selectedDoctorName = doc?.name;
                        _selectedClinicName = doc?.clinicName;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Purchase Date
                const SectionHeader(title: "Purchase Date"),
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
                        Icons.calendar_today_outlined,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      "Date of Purchase",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('EEE, dd MMM yyyy').format(_purchaseDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Commercial Overall Value
                const SectionHeader(
                  title: "Overall Purchase Value",
                  subtitle:
                      "Enter total amount without line-by-line product entry",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _amountController,
                        label: "Purchase Amount (₹)",
                        hint: "e.g. 50000",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.currency_rupee,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please enter purchase amount";
                          }
                          final parsed = double.tryParse(val.trim());
                          if (parsed == null || parsed <= 0) {
                            return "Please enter a valid positive amount";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _gstController,
                        label: "GST Amount (₹)",
                        hint: "e.g. 9000",
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.receipt_long_outlined,
                        onChanged: (_) {
                          _customGst = true;
                        },
                      ),
                      const Divider(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Payable",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "₹${NumberFormat('#,##,###.00').format(_totalAmount)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // PTS Calculation Architecture Placeholder
                const SectionHeader(
                  title: "PTS Calculation",
                  subtitle: "Price To Stockist rate and calculated value",
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "PTS Rate",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "Calculating / Not configured",
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "PTS Value",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "—",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryVeryLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.primaryDark,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                "Exact PTS formula pending business configuration. Value will auto-calculate when formula is finalized.",
                                style: TextStyle(
                                  fontSize: 11,
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
                const SizedBox(height: AppSpacing.lg),

                // Optional Notes
                const SectionHeader(title: "Additional Notes"),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: AppTextField(
                    controller: _notesController,
                    label: "Notes / Reference (Optional)",
                    hint: "e.g. Invoice #1024, special payment terms",
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit Button
                AppButton(
                  label: "Save Purchase",
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
