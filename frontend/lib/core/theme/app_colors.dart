import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Luxury Obsidian & Electric Violet Palette
  static const Color primary = Color(0xFF8B5CF6); // Electric Violet
  static const Color primaryLight = Color(0xFF2A1F4E); // Translucent Violet
  static const Color primaryVeryLight = Color(
    0xFF221A40,
  ); // Very Light Dark Violet
  static const Color primaryDark = Color(0xFF6D28D9); // Deep Velvet Violet
  static const Color primaryGlow = Color(0xFFA78BFA); // Soft Ambient Violet

  // Secondary Accent & Radiant Indigo
  static const Color secondary = Color(0xFF6366F1); // Radiant Indigo
  static const Color secondaryLight = Color(0xFF22204D);
  static const Color secondaryDark = Color(0xFF4F46E5);
  static const Color accentNeon = Color(0xFFF43F5E); // Neon Rose

  // Surface & Dark Obsidian Backgrounds
  static const Color background = Color(0xFF090614); // Deep Obsidian Cosmos
  static const Color surface = Color(0xFF130F26); // Card Base
  static const Color surfaceVariant = Color(0xFF1E1738); // Elevated Surface
  static const Color surfaceElevated = Color(
    0xFF1B1635,
  ); // Floating Card / Sheet
  static const Color surfaceGlass = Color(0x351F1742); // Glass Tint
  static const Color border = Color(0xFF2A224D); // Card border
  static const Color borderHighlight = Color(0x33FFFFFF); // Specular Highlight
  static const Color borderFocus = Color(0xFF8B5CF6);

  // Typography
  static const Color textPrimary = Color(
    0xFFF8FAFC,
  ); // Crisp High-Contrast White
  static const Color textSecondary = Color(0xFF94A3B8); // Soft Slate Lavender
  static const Color textMuted = Color(0xFF64748B); // Muted Ash
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF10B981); // Cyber Emerald
  static const Color successLight = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B); // Amber Gold
  static const Color warningLight = Color(0xFF451A03);
  static const Color error = Color(0xFFF43F5E); // Neon Rose / Red
  static const Color errorLight = Color(0xFF4C0519);
  static const Color info = Color(0xFF38BDF8); // Cyan Glow
  static const Color infoLight = Color(0xFF082F49);

  // High-End Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF1C143B), Color(0xFF120E28), Color(0xFF191032)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF), Color(0x258B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Commercial & Field Categories
  static const Color sample = Color(0xFF8B5CF6);
  static const Color promotional = Color(0xFF6366F1);
  static const Color freeSupply = Color(0xFF10B981);
  static const Color paidSale = Color(0xFF10B981);
  static const Color returnType = Color(0xFFF43F5E);
}
