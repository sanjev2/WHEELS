// lib/app/theme/input_decoration_theme.dart (or wherever you keep it)
import 'package:flutter/material.dart';
import 'package:wheels_flutter/app/theme/color.dart';

InputDecorationTheme getInputDecorationTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceWhite,

    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontFamily: 'Inter Regular',
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle(
      color: AppColors.textTertiary,
      fontFamily: 'Inter Regular',
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.borderMedium),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error, width: 1.6),
    ),

    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
