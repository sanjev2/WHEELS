import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wheels_flutter/core/constants/app_constants.dart';
import 'package:wheels_flutter/features/onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  Timer? _timer;

  late final AnimationController _spinController;
  late final AnimationController _pulseController;

  late final Animation<double> _spin;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    // 🔄 Spinning wheel
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _spin = CurvedAnimation(parent: _spinController, curve: Curves.linear);

    // 🌊 Pulse ring (BIM effect)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseScale = Tween<double>(
      begin: 0.7,
      end: 1.7,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    _pulseOpacity = Tween<double>(
      begin: 0.45,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final logoSize = math.min(170.0, width * 0.42);
    final wheelSize = math.min(60.0, width * 0.15);
    final ringSize = wheelSize + 16;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_spinController, _pulseController]),
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🟢 Static Logo (NO pulse, NO rotation)
                Image.asset(
                  AppConstants.logoPath,
                  width: logoSize,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                // 🔄 Spinning Wheel + Pulse Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse ring (behind wheel)
                    Opacity(
                      opacity: _pulseOpacity.value,
                      child: Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          width: ringSize,
                          height: ringSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF5A9C41),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Rotating wheel image
                    Transform.rotate(
                      angle: _spin.value * 2 * math.pi,
                      child: Image.asset(
                        AppConstants.wheelSpinPath,
                        width: wheelSize,
                        height: wheelSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
