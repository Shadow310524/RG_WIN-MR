import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';

enum OfflineSyncStatus { online, offline, syncing }

class OfflineBanner extends StatelessWidget {
  final OfflineSyncStatus status;
  final int pendingCount;
  final VoidCallback? onSyncTap;

  const OfflineBanner({
    super.key,
    required this.status,
    this.pendingCount = 0,
    this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    if (status == OfflineSyncStatus.online && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String text;

    switch (status) {
      case OfflineSyncStatus.offline:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        icon = Icons.cloud_off_rounded;
        text = pendingCount > 0
            ? "Offline Mode ($pendingCount pending changes will sync online)"
            : "Offline Mode — Working from local database";
        break;
      case OfflineSyncStatus.syncing:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primaryDark;
        icon = Icons.sync_rounded;
        text = "Syncing changes with server...";
        break;
      case OfflineSyncStatus.online:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        text = "All changes synced";
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      color: bgColor,
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (onSyncTap != null && status == OfflineSyncStatus.offline)
            InkWell(
              onTap: onSyncTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  "Retry",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
