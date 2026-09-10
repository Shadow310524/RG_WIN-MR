import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';

class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.secondaryDark : AppColors.textSecondary,
        ),
      ),
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.secondaryDark : AppColors.textMuted,
            )
          : null,
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.secondaryLight,
      checkmarkColor: AppColors.secondaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(
          color: isSelected ? AppColors.secondary : AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}
