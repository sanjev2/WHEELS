import 'package:flutter/material.dart';
import 'package:wheels_flutter/other/theme/input_decoration_theme.dart';
import 'app_bar_theme.dart';
import 'bottom_navigation_theme.dart';
import 'button_theme.dar';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF5A9C41),
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5A9C41),
      brightness: Brightness.light,
    ),

    // Apply all your theme parts
    appBarTheme: getAppBarTheme(),
    bottomNavigationBarTheme: getBottomNavigationTheme(),
    elevatedButtonTheme: getElevatedButtonTheme(),
    inputDecorationTheme: getInputDecorationTheme(),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Inter Bold',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5A9C41),
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter Bold',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter Regular',
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter Regular',
        fontSize: 14,
        color: Colors.grey,
      ),
    ),
  );
}
