import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';

enum OfflineSyncStatus { online, offline, syncing }

/// Futuristic Glowing Sync & Offline Telemetry Banner.
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

    final Color accentColor;
    final IconData icon;
    final String text;

    switch (status) {
      case OfflineSyncStatus.offline:
        accentColor = AppColors.warning;
        icon = Icons.cloud_off_rounded;
        text = pendingCount > 0
            ? "Offline Mode ($pendingCount pending changes queued)"
            : "Offline Mode — Working from local database";
        break;
      case OfflineSyncStatus.syncing:
        accentColor = AppColors.primaryGlow;
        icon = Icons.sync_rounded;
        text = "Syncing changes with server...";
        break;
      case OfflineSyncStatus.online:
        accentColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        text = "All local changes synced";
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accentColor.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onSyncTap != null && status == OfflineSyncStatus.offline) ...[
            const SizedBox(width: AppSpacing.xs),
            SpringButton(
              onTap: onSyncTap,
              scaleDown: 0.94,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  "Sync Now",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
