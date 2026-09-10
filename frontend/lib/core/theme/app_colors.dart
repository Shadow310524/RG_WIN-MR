import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Lavender Identity
  static const Color primary = Color(0xFF8B7CF6); // Primary Lavender
  static const Color primaryDark = Color(0xFF6D5CE7); // Deep Lavender
  static const Color primaryLight = Color(0xFFEEEAFE); // Soft Lavender
  static const Color primaryVeryLight = Color(
    0xFFF7F5FF,
  ); // Very Light Lavender
  static const Color primaryGlow = Color(0xFF8B7CF6); // Kept for compatibility

  // Secondary & Accents
  static const Color secondary = Color(0xFF6D5CE7);
  static const Color secondaryLight = Color(0xFFEEEAFE);
  static const Color secondaryDark = Color(0xFF5B4BC4);

  // Background & Surfaces
  static const Color background = Color(0xFFFAF9FD); // Clean Light Background
  static const Color surface = Color(0xFFFFFFFF); // Pure White Cards
  static const Color surfaceVariant = Color(
    0xFFF7F5FF,
  ); // Soft Lavender Surface
  static const Color surfaceElevated = Color(
    0xFFFFFFFF,
  ); // Elevated White Surface
  static const Color surfaceGlass = Color(0xFFF7F5FF); // Light Tint

  // Borders & Dividers
  static const Color border = Color(0xFFE8E5F3); // Clean Soft Lavender Border
  static const Color borderHighlight = Color(0xFFEDE9FE);
  static const Color borderFocus = Color(0xFF8B7CF6);

  // Typography
  static const Color textPrimary = Color(0xFF202033); // High-Contrast Primary
  static const Color textSecondary = Color(0xFF6F6B7D); // Soft Slate Secondary
  static const Color textMuted = Color(0xFF9D99A9); // Muted Text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on Lavender

  // Status & Feedback
  static const Color success = Color(0xFF2E9B68); // Calibrated Emerald Green
  static const Color successLight = Color(0xFFE8F6EF);
  static const Color warning = Color(0xFFD99020); // Warm Amber
  static const Color warningLight = Color(0xFFFEF6E9);
  static const Color error = Color(0xFFD9534F); // Crimson Red
  static const Color errorLight = Color(0xFFFDF0F0);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Gradients (Subtle & Restrained)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B7CF6), Color(0xFF6D5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F6FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient softLavenderGradient = LinearGradient(
    colors: [Color(0xFFEEEAFE), Color(0xFFF7F5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Commercial & Field Categories
  static const Color sample = Color(0xFF8B7CF6);
  static const Color promotional = Color(0xFF6D5CE7);
  static const Color freeSupply = Color(0xFF2E9B68);
  static const Color paidSale = Color(0xFF2E9B68);
  static const Color returnType = Color(0xFFD9534F);
}
