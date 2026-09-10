import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';

class DoctorsShellScreen extends StatelessWidget {
  const DoctorsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: AppCard(
        child: AppEmptyState(
          icon: Icons.person_search_outlined,
          title: "Doctor Directory Foundation",
          description:
              "Area management, medical associations, and duplicate doctor detection algorithms are scheduled for Phase 3 implementation.",
        ),
      ),
    );
  }
}
