import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Wheels';
  static const String appVersion = '1.0.0';

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String carImage = 'assets/images/car.png';

  // Onboarding Images
  static const String onboarding1 = 'assets/images/page1.png';
  static const String onboarding2 = 'assets/images/page2.png';
  static const String onboarding3 = 'assets/images/page3.png';

  // 🎨 Colors (USED BY DASHBOARD)
  static const Color primaryGreen = Color(0xFF5A9C41);
  static const Color darkGreen = Color(0xFF3E8B3A);
  static const Color surfaceGreen = Color(0xFFE8F5E9);
  static const Color pinkAccent = Color(0xFFF48FB1);

  // Old names (optional – keep for compatibility)
  static const Color primaryColor = primaryGreen;
  static const Color secondaryColor = darkGreen;
}
