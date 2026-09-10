import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';

class FollowupsShellScreen extends StatelessWidget {
  const FollowupsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: AppCard(
        child: AppEmptyState(
          icon: Icons.event_available_outlined,
          title: "Follow-up Commitments Foundation",
          description:
              "Tabbed status views (Due Today, Overdue, Upcoming, Completed) with quick-complete actions will be implemented in Phase 5.",
        ),
      ),
    );
  }
}
