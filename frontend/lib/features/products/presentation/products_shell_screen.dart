import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/app_card.dart';
import 'package:rgwin_crm/core/widgets/app_empty_state.dart';

class ProductsShellScreen extends StatelessWidget {
  const ProductsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: AppCard(
        child: AppEmptyState(
          icon: Icons.inventory_2_outlined,
          title: "Healix Product Catalog (Read-Only)",
          description:
              "The 31 authoritative Healix products from https://healix-rgwin.onrender.com/api/v1 will be synchronized and cached for clinical profile viewing and offline field selection in Phase 4.",
        ),
      ),
    );
  }
}
