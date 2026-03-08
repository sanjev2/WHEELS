import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isSupported() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final deviceSupported = await _auth.isDeviceSupported();
      return canCheck || deviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> hasEnrolledBiometrics() async {
    try {
      final list = await _auth.getAvailableBiometrics();
      return list.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate with biometrics',
  }) async {
    try {
      final supported = await isSupported();
      if (!supported) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } on PlatformException {
      // no-op
    }
  }
}
