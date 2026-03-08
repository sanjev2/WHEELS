import 'package:flutter/material.dart';
import 'package:wheels_flutter/app/theme/input_decoration.dart';
import 'app_bar_theme.dart';
import 'bottom_navigation_theme.dart';
import 'button_theme.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF5A9C41),
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5A9C41),
      brightness: Brightness.light,
    ),
    appBarTheme: getAppBarTheme(),
    bottomNavigationBarTheme: getBottomNavigationTheme(),
    elevatedButtonTheme: getElevatedButtonTheme(),
    inputDecorationTheme: getInputDecorationTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFF5A9C41),
    scaffoldBackgroundColor: const Color(0xFF0B0F12),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5A9C41),
      brightness: Brightness.dark,
    ),
    appBarTheme: getAppBarTheme().copyWith(
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: getBottomNavigationTheme().copyWith(
      backgroundColor: const Color(0xFF0F172A),
      selectedItemColor: const Color(0xFF5A9C41),
      unselectedItemColor: Colors.white70,
    ),
    elevatedButtonTheme: getElevatedButtonTheme(),
    inputDecorationTheme: getInputDecorationTheme(),
  );
}
