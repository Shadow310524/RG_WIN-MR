import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Lavender Visual Identity
  static const Color primary = Color(0xFF8B7CF6); // Primary Lavender
  static const Color primaryLight = Color(0xFFEEEAFE); // Soft Lavender
  static const Color primaryDark = Color(0xFF6D5CE7); // Deep Lavender
  static const Color primaryVeryLight = Color(
    0xFFF7F5FF,
  ); // Very Light Lavender

  // Secondary Accent & Brand
  static const Color secondary = Color(0xFF6D5CE7); // Deep Lavender accent
  static const Color secondaryLight = Color(0xFFEEEAFE);
  static const Color secondaryDark = Color(0xFF5646D0);

  // Surface & Neutral Backgrounds
  static const Color background = Color(0xFFFAF9FD); // Calm lavender background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(
    0xFFF7F5FF,
  ); // Very Light Lavender surface
  static const Color border = Color(0xFFEAE6F8); // Subtle lavender border
  static const Color borderFocus = Color(0xFF8B7CF6);

  // Typography
  static const Color textPrimary = Color(0xFF202033); // Slate dark
  static const Color textSecondary = Color(0xFF6F6B7D); // Subdued text
  static const Color textMuted = Color(0xFF9D99A9); // Muted / placeholder
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF2E9B68); // Soft emerald
  static const Color successLight = Color(0xFFE8F6EF);
  static const Color warning = Color(0xFFD99020); // Warm amber
  static const Color warningLight = Color(0xFFFDF4E5);
  static const Color error = Color(0xFFD9534F); // Coral red
  static const Color errorLight = Color(0xFFFCEBEA);
  static const Color info = Color(0xFF4B7BEC); // Trust blue
  static const Color infoLight = Color(0xFFEEF3FC);

  // Commercial & Field Categories
  static const Color sample = Color(0xFF8B7CF6);
  static const Color promotional = Color(0xFF6D5CE7);
  static const Color freeSupply = Color(0xFF2E9B68);
  static const Color paidSale = Color(0xFF2E9B68);
  static const Color returnType = Color(0xFFD9534F);
}
