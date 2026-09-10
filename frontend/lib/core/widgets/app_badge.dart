import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';

enum AppBadgeVariant {
  active,
  inactive,
  archived,
  pending,
  completed,
  overdue,
  sample,
  promotional,
  info,
  custom,
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final Color? customColor;
  final Color? customBackgroundColor;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.info,
    this.customColor,
    this.customBackgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    switch (variant) {
      case AppBadgeVariant.active:
      case AppBadgeVariant.completed:
        textColor = AppColors.success;
        bgColor = AppColors.successLight;
        break;
      case AppBadgeVariant.pending:
        textColor = AppColors.warning;
        bgColor = AppColors.warningLight;
        break;
      case AppBadgeVariant.overdue:
        textColor = AppColors.error;
        bgColor = AppColors.errorLight;
        break;
      case AppBadgeVariant.sample:
        textColor = AppColors.sample;
        bgColor = AppColors.infoLight;
        break;
      case AppBadgeVariant.promotional:
        textColor = AppColors.promotional;
        bgColor = const Color(0xFFEDE9FE);
        break;
      case AppBadgeVariant.inactive:
      case AppBadgeVariant.archived:
        textColor = AppColors.textMuted;
        bgColor = AppColors.surfaceVariant;
        break;
      case AppBadgeVariant.info:
        textColor = AppColors.secondaryDark;
        bgColor = AppColors.secondaryLight;
        break;
      case AppBadgeVariant.custom:
        textColor = customColor ?? AppColors.textPrimary;
        bgColor = customBackgroundColor ?? AppColors.surfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
