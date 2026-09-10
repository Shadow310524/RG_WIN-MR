import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? confirmLabel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final AppButtonVariant confirmVariant;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel,
    this.onConfirm,
    this.cancelLabel = "Cancel",
    this.onCancel,
    this.confirmVariant = AppButtonVariant.primary,
    this.isDestructive = false,
  });

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = "Confirm",
    String cancelLabel = "Cancel",
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        confirmLabel: confirmLabel,
        confirmVariant: isDestructive
            ? AppButtonVariant.danger
            : AppButtonVariant.primary,
        onConfirm: () => Navigator.of(context).pop(true),
        cancelLabel: cancelLabel,
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.md,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: content,
      actions: [
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.text,
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
        ),
        if (confirmLabel != null)
          AppButton(
            label: confirmLabel!,
            variant: isDestructive ? AppButtonVariant.danger : confirmVariant,
            onPressed: onConfirm,
          ),
      ],
    );
  }
}
