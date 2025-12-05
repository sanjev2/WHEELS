import 'package:flutter/material.dart';
import 'package:wheels_flutter/screens/login_screen.dart';
import 'package:wheels_flutter/widgets/my_button.dart';
import 'onboarding2.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  void _goToNext(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const Onboarding2();
        },
      ),
    );
  }

  void _skipToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              Expanded(
                flex: 3,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Image.asset(
                        'assets/images/page1.png',
                        fit: BoxFit.contain,
                        width: constraints.maxWidth * 0.8,
                      );
                    },
                  ),
                ),
              ),

              const Spacer(flex: 1),

              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Text(
                    'Find service that\nfit your ride',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E8B3A),
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Text(
                    'Compare the prices and deals for services that fit\n'
                    'your vehicle to find the best value.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(true),
                  const SizedBox(width: 6),
                  _buildDot(false),
                  const SizedBox(width: 6),
                  _buildDot(false),
                ],
              ),

              const Spacer(flex: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextButton(
                      onPressed: () {
                        _skipToLogin(context);
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF3E8B3A),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  Flexible(
                    child: MyButton(
                      onPressed: () {
                        _goToNext(context);
                      },
                      text: 'Next',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 8 : 6,
      height: isActive ? 8 : 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3E8B3A) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}
