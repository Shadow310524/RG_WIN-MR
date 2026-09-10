import 'package:flutter/material.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/widgets/spring_button.dart';

/// Clean, professional light lavender card container with subtle borders and soft shadows.
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
                  (isGlass ? AppColors.surfaceVariant : AppColors.surface))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.border, width: 1.0),
        boxShadow:
            boxShadow ??
            const [
              BoxShadow(
                color: Color(0x08202033),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primaryLight,
          highlightColor: AppColors.primaryVeryLight,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return SpringButton(onTap: onTap, scaleDown: 0.98, child: cardBody);
    }

    return cardBody;
  }
}
