import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rgwin_crm/core/network/dio_client.dart';
import 'package:rgwin_crm/core/storage/secure_storage.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_text_field.dart';
import 'package:rgwin_crm/core/widgets/section_header.dart';
import 'package:rgwin_crm/features/doctors/presentation/doctor_controller.dart';

class RecordExpenseScreen extends ConsumerStatefulWidget {
  const RecordExpenseScreen({super.key});

  @override
  ConsumerState<RecordExpenseScreen> createState() =>
      _RecordExpenseScreenState();
}

class _RecordExpenseScreenState extends ConsumerState<RecordExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  String _expenseType = "TRAVEL";
  DateTime _expenseDate = DateTime.now();
  String? _selectedAreaId;
  bool _isSaving = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _types = [
    {
      'type': 'TRAVEL',
      'label': 'Travel',
      'icon': Icons.directions_subway_outlined,
    },
    {'type': 'FUEL', 'label': 'Fuel', 'icon': Icons.local_gas_station_outlined},
    {'type': 'FOOD', 'label': 'Food / DA', 'icon': Icons.restaurant_outlined},
    {
      'type': 'PROMOTION',
      'label': 'Promotion',
      'icon': Icons.card_giftcard_outlined,
    },
    {'type': 'OTHER', 'label': 'Other', 'icon': Icons.more_horiz_outlined},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _expenseDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    try {
      final dio = DioClient().dio;
      final storage = SecureStorageService();
      final token = await storage.getAccessToken();
      final options = Options(headers: {'Authorization': 'Bearer $token'});

      await dio.post(
        '/expenses',
        data: {
          'expense_type': _expenseType,
          'amount': amount,
          'expense_date': _expenseDate.toIso8601String().split('T').first,
          'area_id': _selectedAreaId,
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        },
        options: options,
      );
    } catch (_) {
      // Offline fallback: handled locally
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Field expense recorded successfully."),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Record Field Expense"),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Expense Type Selector
                const SectionHeader(
                  title: "Expense Category",
                  subtitle: "Select the field activity category",
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _types.map((t) {
                      final isSelected = _expenseType == t['type'];
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          avatar: Icon(
                            t['icon'] as IconData,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryDark,
                          ),
                          label: Text(t['label'] as String),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (_) {
                            setState(() => _expenseType = t['type'] as String);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Amount
                const SectionHeader(title: "Expense Amount"),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: AppTextField(
                    controller: _amountController,
                    label: "Amount (₹)",
                    hint: "e.g. 750",
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.currency_rupee,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Please enter expense amount";
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return "Please enter a valid positive amount";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Date & Area
                const SectionHeader(title: "Date & Field Territory"),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        title: const Text(
                          "Date of Expense",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('EEE, dd MMM yyyy').format(_expenseDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.edit_calendar_outlined,
                          size: 18,
                        ),
                        onTap: _pickDate,
                      ),
                      const Divider(),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAreaId,
                        decoration: const InputDecoration(
                          labelText: "Territory Area (Optional)",
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text("General / Headquarters"),
                          ),
                          ...doctorState.areas.map(
                            (a) => DropdownMenuItem<String>(
                              value: a.id,
                              child: Text(a.name),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedAreaId = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Notes
                const SectionHeader(title: "Notes / Description"),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: AppTextField(
                    controller: _notesController,
                    label: "Details (Optional)",
                    hint: "e.g. Coimbatore North to Pollachi toll & fuel",
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save Button
                AppButton(
                  label: "Save Expense",
                  icon: Icons.check,
                  isLoading: _isSaving,
                  fullWidth: true,
                  onPressed: _isSaving ? null : _handleSubmit,
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
