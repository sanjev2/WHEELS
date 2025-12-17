import 'package:flutter/material.dart';

Color getScaffoldBackgroundColor() {
  return Colors.grey.shade100;
}

ThemeData applyScaffoldTheme(ThemeData baseTheme) {
  return baseTheme.copyWith(
    scaffoldBackgroundColor: getScaffoldBackgroundColor(),
  );
}
