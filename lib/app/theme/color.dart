import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryGreen = Color(0xFF5A9C41);
  static const Color darkGreen = Color(0xFF3E8B3A);
  static const Color accentGreen = Color(0xFF3E8B3A);

  // Secondary Colors
  static const Color pinkAccent = Color(0xFFEF6C73);
  static const Color orangeAccent = Color(0xFFF4A261);
  static const Color blueAccent = Color(0xFF2A9D8F);

  // Surface Colors
  static const Color surfaceGreen = Color(0xFFF6FAF4);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFCCCCCC);
  static const Color borderDark = Color(0xFF888888);

  // State Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5A9C41), Color(0xFF3E8B3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
