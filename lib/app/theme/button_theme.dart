import 'package:flutter/material.dart';
import 'package:wheels_flutter/app/theme/color.dart';

ElevatedButtonThemeData getElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return AppColors.primaryGreen.withOpacity(0.5);
        }
        return AppColors.primaryGreen;
      }),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter Regular',
        ),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      minimumSize: MaterialStateProperty.all(const Size(double.infinity, 52)),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return 0;
        return 2;
      }),
    ),
  );
}
