import 'package:flutter/material.dart';

/// Design tokens extracted directly from Google Stitch project:
/// 'PharmaPulse Executive Dashboard' (projects/7640799912351310134).
class AppColors {
  AppColors._();

  // Stitch Primary Iris Identity
  static const Color primary = Color(0xFF5949C0); // Vibrant Royal Iris
  static const Color primaryDark = Color(0xFF4330AA); // Deep Iris
  static const Color primaryContainer = Color(0xFF7263DB); // Elevated Primary
  static const Color primaryLight = Color(0xFFE5DEFF); // Soft Fixed Lavender
  static const Color primaryVeryLight = Color(0xFFF5F2FF); // Container Low
  static const Color primaryGlow = Color(0xFF7263DB); // Soft Iris Glow

  // Secondary & Accents
  static const Color secondary = Color(0xFF5744D0);
  static const Color secondaryContainer = Color(0xFF705FEA);
  static const Color secondaryLight = Color(0xFFE4DFFF);
  static const Color secondaryDark = Color(0xFF4129BA);

  // Background & Surfaces
  static const Color background = Color(0xFFFCF8FF); // Stitch Warm Tint Canvas
  static const Color surface = Color(0xFFFFFFFF); // Pure White Cards
  static const Color surfaceVariant = Color(0xFFE2E0FA); // Surface Highest
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Pure White Elevated
  static const Color surfaceGlass = Color(0xFFF5F2FF); // Container Low
  static const Color surfaceContainer = Color(0xFFEFECFF); // Container Card
  static const Color surfaceContainerLow = Color(0xFFF5F2FF); // Container Low
  static const Color surfaceContainerHigh = Color(0xFFE8E5FF); // Container High
  static const Color surfaceContainerHighest = Color(
    0xFFE2E0FA,
  ); // Container Highest

  // Borders & Dividers
  static const Color border = Color(0xFFE8E5F3); // Soft Lavender Border
  static const Color borderHighlight = Color(
    0xFFE5DEFF,
  ); // Primary Fixed Border
  static const Color borderFocus = Color(0xFF5949C0); // Focus Iris Border
  static const Color outline = Color(0xFF787584); // Stitch Outline
  static const Color outlineVariant = Color(0xFFC9C4D5); // Soft Outline

  // Typography
  static const Color textPrimary = Color(
    0xFF1A1A2C,
  ); // Stitch High-Contrast Ink
  static const Color textSecondary = Color(0xFF474553); // On-Surface-Variant
  static const Color textMuted = Color(0xFF787584); // Muted Outline Text
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // Crisp White on Primary

  // Status & Feedback
  static const Color success = Color(0xFF16A34A); // Stitch Emerald Green
  static const Color successLight = Color(0xFFDCFCE7); // Emerald 100
  static const Color warning = Color(0xFFD97706); // Warm Amber
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color error = Color(0xFFBA1A1A); // Stitch Crimson Error
  static const Color errorLight = Color(0xFFFFDAD6); // Error Container
  static const Color info = Color(0xFF3B82F6); // Info Blue
  static const Color infoLight = Color(0xFFEFF6FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5949C0), Color(0xFF7263DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F2FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient softLavenderGradient = LinearGradient(
    colors: [Color(0xFFE5DEFF), Color(0xFFF5F2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Commercial & Field Categories
  static const Color sample = Color(0xFF5949C0);
  static const Color promotional = Color(0xFF705FEA);
  static const Color freeSupply = Color(0xFF16A34A);
  static const Color paidSale = Color(0xFF16A34A);
  static const Color returnType = Color(0xFFBA1A1A);
}
