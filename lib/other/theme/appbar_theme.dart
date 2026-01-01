import 'package:flutter/material.dart';

AppBarTheme getAppBarTheme() {
  return const AppBarTheme(
    centerTitle: true,

    elevation: 0,
    scrolledUnderElevation: 4,

    backgroundColor: Color(0xFF5A9C41),
    shadowColor: Colors.black,

    titleTextStyle: TextStyle(
      fontFamily: 'Inter Bold',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),

    iconTheme: IconThemeData(color: Colors.white),
  );
}
