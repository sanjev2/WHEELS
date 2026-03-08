import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    return ThemeModeController();
  },
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.light) {
    _start();
  }

  StreamSubscription<int>? _sub;

  // hysteresis to avoid flicker
  static const int nightLux = 15;
  static const int dayLux = 35;

  void _start() {
    try {
      _sub = Light().lightSensorStream.listen((lux) {
        final current = state;
        if (current == ThemeMode.light && lux < nightLux) {
          state = ThemeMode.dark;
        } else if (current == ThemeMode.dark && lux > dayLux) {
          state = ThemeMode.light;
        }
      });
    } catch (_) {
      // if sensor not available, ignore
    }
  }

  void setManual(ThemeMode mode) => state = mode;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
