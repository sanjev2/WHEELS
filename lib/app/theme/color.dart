import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =========================
  // Core (used across the app)
  // =========================

  /// App backgrounds
  static const Color bg = Color(0xFFF5F7F7); // ✅ matches dashboard scaffold bg
  static const Color surface = Color(0xFFFFFFFF);

  // Primary brand (UPDATED to your dashboard green)
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color secondaryGreen = Color(0xFF10B981);

  // Keep old names too (so old code won’t break)
  static const Color darkGreen = Color(0xFF15803D);
  static const Color accentGreen = secondaryGreen;

  // Secondary accents (kept)
  static const Color pinkAccent = Color(0xFFEF6C73);
  static const Color orangeAccent = Color(0xFFF4A261);
  static const Color blueAccent = Color(0xFF2A9D8F);

  // Surfaces (UPDATED)
  static const Color surfaceGreen = Color(0xFFEFFAF3); // chip bg
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F7F7);

  // Text (UPDATED to match dashboard)
  static const Color textPrimary = Color(0xFF0B1220);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textSubtle = Colors.black38;
  static const Color textWhite = Color(0xFFFFFFFF);

  // Borders (UPDATED)
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);

  // Extra border/shadow tokens used in your UI
  static Color borderSofter = Colors.black.withOpacity(0.08);
  static Color shadowSoft = Colors.black.withOpacity(0.06);

  // State colors (kept)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Gradients (UPDATED to match dashboard)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGrad = primaryGradient;
}
