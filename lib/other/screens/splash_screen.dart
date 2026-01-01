import 'package:flutter/material.dart';
import 'package:wheels_flutter/other/screens/onboarding_screen/onboarding1.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void navigateToOnboarding(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const Onboarding1();
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateToOnboarding(context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/images/logo.png",
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
