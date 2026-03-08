import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/core/constants/app_constants.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:wheels_flutter/features/dashboard/dahsboard_page.dart';
import 'package:wheels_flutter/features/onboarding/onboarding_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  Timer? _timer;

  late final AnimationController _spinController;
  late final AnimationController _pulseController;

  late final Animation<double> _spin;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _spin = CurvedAnimation(parent: _spinController, curve: Curves.linear);

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

    _startFlow();
  }

  void _startFlow() {
    _timer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await ref.read(authViewModelProvider.notifier).init();

      if (!mounted) return;

      final status = ref.read(authViewModelProvider).status;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => status == AuthStatus.authenticated
              ? const DashboardPage()
              : const OnboardingPage(),
        ),
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
                Image.asset(
                  AppConstants.logoPath,
                  width: logoSize,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
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
