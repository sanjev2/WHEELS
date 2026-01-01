import 'package:flutter/material.dart';

ElevatedButtonThemeData getElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5A9C41),
      foregroundColor: Colors.white,

      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter Regular',
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
  );
}
