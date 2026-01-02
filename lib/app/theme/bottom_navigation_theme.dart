import 'package:flutter/material.dart';
import 'package:wheels_flutter/app/theme/color.dat';

BottomNavigationBarThemeData getBottomNavigationTheme() {
  return const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primaryGreen,
    unselectedItemColor: Colors.grey,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );
}
