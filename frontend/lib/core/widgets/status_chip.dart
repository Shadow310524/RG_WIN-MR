import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';

enum StatusChipVariant { success, warning, error, info, neutral }

/// Translucent Neon Status Pill with glowing beacon dot indicator.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusChipVariant variant;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.variant = StatusChipVariant.neutral,
    this.icon,
  });

  factory StatusChip.fromStatus(String status) {
    final s = status.toUpperCase().trim();
    if (s == 'ACTIVE' ||
        s == 'COMPLETED' ||
        s == 'SYNCED' ||
        s == 'CONFIRMED') {
      return StatusChip(label: status, variant: StatusChipVariant.success);
    }
    if (s == 'UPCOMING' ||
        s == 'PENDING' ||
        s == 'IN_PROGRESS' ||
        s == 'PENDING SYNC') {
      return StatusChip(label: status, variant: StatusChipVariant.warning);
    }
    if (s == 'INACTIVE' ||
        s == 'CANCELLED' ||
        s == 'FAILED' ||
        s == 'REFUNDED') {
      return StatusChip(label: status, variant: StatusChipVariant.error);
    }
    if (s == 'ADMIN' || s == 'MR') {
      return StatusChip(label: status, variant: StatusChipVariant.info);
    }
    return StatusChip(label: status, variant: StatusChipVariant.neutral);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case StatusChipVariant.success:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case StatusChipVariant.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case StatusChipVariant.error:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case StatusChipVariant.info:
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
      case StatusChipVariant.neutral:
        bg = AppColors.surfaceElevated;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: fg.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: fg.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: fg.withOpacity(0.8),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
