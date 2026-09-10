import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgwin_crm/core/theme/app_colors.dart';
import 'package:rgwin_crm/core/theme/app_spacing.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';

void main() {
  group('AppTheme & Design Tokens Tests', () {
    test('Lavender Mobile Brand Colors are properly defined', () {
      expect(AppColors.primary, const Color(0xFF8B7CF6));
      expect(AppColors.primaryDark, const Color(0xFF6D5CE7));
      expect(AppColors.primaryLight, const Color(0xFFEEEAFE));
      expect(AppColors.background, const Color(0xFFFAF9FD));
      expect(AppColors.textPrimary, const Color(0xFF202033));
    });

    test('Spacing tokens maintain consistent scale', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 20.0);
    });

    test('Light theme builds with Material 3 enabled', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.cardTheme.elevation, 0);
    });
  });
}
