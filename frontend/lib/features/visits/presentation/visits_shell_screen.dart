import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';

class VisitsShellScreen extends StatelessWidget {
  const VisitsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: AppCard(
        child: AppEmptyState(
          icon: Icons.assignment_outlined,
          title: "Field Visit Management Foundation",
          description:
              "Fast one-handed mobile field visit logging, discussed products, sample distributions, and follow-up generation are scheduled for Phase 5.",
        ),
      ),
    );
  }
}
