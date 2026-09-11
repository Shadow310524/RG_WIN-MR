import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';

void main() {
  group('AppTheme & Design Tokens Tests', () {
    test('Lavender Brand Colors are properly defined', () {
      expect(AppColors.primary, const Color(0xFF5949C0));
      expect(AppColors.primaryDark, const Color(0xFF4330AA));
      expect(AppColors.primaryLight, const Color(0xFFE5DEFF));
      expect(AppColors.background, const Color(0xFFFCF8FF));
      expect(AppColors.textPrimary, const Color(0xFF1A1A2C));
    });

    test('Spacing tokens maintain consistent scale', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 20.0);
    });

    test('Theme builds with Material 3 enabled', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.cardTheme.elevation, 0);
    });
  });
}
