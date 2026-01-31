import 'package:flutter/material.dart';
import 'package:wheels_flutter/app/theme/color.dart';

ElevatedButtonThemeData getElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      // ✅ prevents Flutter from interpolating text styles between states
      animationDuration: Duration.zero,

      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.primaryGreen.withOpacity(0.5);
        }
        return AppColors.primaryGreen;
      }),

      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),

      // ✅ IMPORTANT: explicitly set inherit (same for all states)
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          inherit: true,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter Regular',
        ),
      ),

      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 52)),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return 0;
        return 2;
      }),
    ),
  );
}
