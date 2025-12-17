import 'package:flutter/material.dart';
import 'package:wheels_flutter/theme/appbar_theme.dart';
import 'package:wheels_flutter/theme/bottom_navigation_theme.dart';
import 'package:wheels_flutter/theme/elevatedbutton_theme.dart';
import 'package:wheels_flutter/theme/input_decoration_theme.dart';
import 'package:wheels_flutter/theme/scaffold_theme.dart';

ThemeData getApplicationTheme() {
  const Color primaryColor = Color(0xFF5A9C41);

  ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter Regular',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: getAppBarTheme(),
    bottomNavigationBarTheme: getBottomNavigationTheme(),
    elevatedButtonTheme: getElevatedButtonTheme(),
    inputDecorationTheme: getInputDecorationTheme(),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryColor),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w400),
      displayMedium: TextStyle(fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontWeight: FontWeight.w400),

      headlineLarge: TextStyle(fontWeight: FontWeight.w400),
      headlineMedium: TextStyle(fontWeight: FontWeight.w400),
      headlineSmall: TextStyle(fontWeight: FontWeight.w400),

      titleLarge: TextStyle(fontWeight: FontWeight.w400),
      titleMedium: TextStyle(fontWeight: FontWeight.w400),
      titleSmall: TextStyle(fontWeight: FontWeight.w400),

      bodyLarge: TextStyle(fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontWeight: FontWeight.w400),

      labelLarge: TextStyle(fontWeight: FontWeight.w400),
      labelMedium: TextStyle(fontWeight: FontWeight.w400),
      labelSmall: TextStyle(fontWeight: FontWeight.w400),
    ),
  );

  theme = applyScaffoldTheme(theme);

  return theme;
}
