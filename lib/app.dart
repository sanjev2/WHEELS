import 'package:flutter/material.dart';
import 'package:wheels_flutter/screens/splash_screen.dart';
import 'package:wheels_flutter/theme/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wheels',
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}
