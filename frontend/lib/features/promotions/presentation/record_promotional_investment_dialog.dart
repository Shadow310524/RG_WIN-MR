import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_text_field.dart';
import 'package:rgwin_crm/features/promotions/presentation/promotional_investment_controller.dart';

Future<bool?> showRecordPromotionalInvestmentSheet(
  BuildContext context, {
  required String doctorId,
  required String doctorName,
  String? clinicName,
  String? visitId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => RecordPromotionalInvestmentModal(
      doctorId: doctorId,
      doctorName: doctorName,
      clinicName: clinicName,
      visitId: visitId,
    ),
  );
}

class RecordPromotionalInvestmentModal extends ConsumerStatefulWidget {
  final String doctorId;
  final String doctorName;
  final String? clinicName;
  final String? visitId;

  const RecordPromotionalInvestmentModal({
    super.key,
    required this.doctorId,
    required this.doctorName,
    this.clinicName,
    this.visitId,
  });

  @override
  ConsumerState<RecordPromotionalInvestmentModal> createState() =>
      _RecordPromotionalInvestmentModalState();
}

class _RecordPromotionalInvestmentModalState
    extends ConsumerState<RecordPromotionalInvestmentModal> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = "SAMPLE";
  final DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  String? _amountError;

  final List<Map<String, String>> _categories = const [
    {"type": "SAMPLE", "label": "Sample"},
    {"type": "PROMOTIONAL_UNIT", "label": "Promotional Unit"},
    {"type": "FREE_SUPPLY", "label": "Free Supply"},
    {"type": "PROMOTIONAL_MATERIAL", "label": "Material"},
    {"type": "OTHER", "label": "Other"},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = "Enter a valid positive amount (e.g. 500)";
      });
      return;
    }

    setState(() {
      _amountError = null;
      _isSubmitting = true;
    });

    final controller = ref.read(
      promotionalInvestmentControllerProvider.notifier,
    );
    final result = await controller.recordInvestment(
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
      visitId: widget.visitId,
      amount: amount,
      investmentType: _selectedType,
      investmentDate: _selectedDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Promotional investment of ₹${NumberFormat('#,##,###.00').format(amount)} recorded",
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xl + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Record Promotional Investment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "${widget.doctorName}${widget.clinicName != null ? ' • ${widget.clinicName}' : ''}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Type Selector
            const Text(
              "INVESTMENT TYPE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedType == cat["type"];
                return ChoiceChip(
                  label: Text(cat["label"]!),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = cat["type"]!);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount Input
            AppTextField(
              label: "Monetary Investment (₹)",
              hint: "e.g. 750",
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixIcon: Icons.currency_rupee,
              errorText: _amountError,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Notes Input
            AppTextField(
              label: "Promotional Notes (Optional)",
              hint:
                  "Details of samples, promotional items or supplies provided",
              controller: _notesController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),

            // Submit Button
            AppButton(
              label: "Save Promotional Investment",
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
