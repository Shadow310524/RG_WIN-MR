import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';

/// Luxury Obsidian & Glassmorphic Container Card with optional tactile spring physics.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final Gradient? gradient;
  final bool isGlass;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.gradient,
    this.isGlass = false,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lg;

    Widget cardBody = Container(
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ??
                  (isGlass ? AppColors.surfaceElevated : AppColors.surface))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              borderColor ??
              (isGlass ? AppColors.borderHighlight : AppColors.border),
          width: isGlass ? 1.2 : 1.0,
        ),
        boxShadow:
            boxShadow ??
            (isGlass
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.primaryGlow.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, -2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primaryGlow.withOpacity(0.12),
          highlightColor: AppColors.primaryGlow.withOpacity(0.06),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return SpringButton(onTap: onTap, scaleDown: 0.97, child: cardBody);
    }

    return cardBody;
  }
}
