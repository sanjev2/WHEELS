import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/core/services/biometric/biometric_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.flutter.io/local_auth');

  late BiometricService service;

  setUp(() {
    service = BiometricService();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'isSupported returns true when biometrics or device support exists',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'deviceSupportsBiometrics':
                return true;
              case 'isDeviceSupported':
                return true;
            }
            return null;
          });

      final result = await service.isSupported();

      expect(result, true);
    },
  );

  test(
    'hasEnrolledBiometrics returns true when enrolled biometrics exist',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getAvailableBiometrics':
                return <String>['fingerprint'];
            }
            return null;
          });

      final result = await service.hasEnrolledBiometrics();

      expect(result, true);
    },
  );

  test('authenticate returns true when platform auth succeeds', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'deviceSupportsBiometrics':
              return true;
            case 'isDeviceSupported':
              return true;
            case 'authenticate':
              return true;
          }
          return null;
        });

    final result = await service.authenticate(reason: 'Test authentication');

    expect(result, true);
  });

  test('stopAuthentication completes safely', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'stopAuthentication':
              return true;
          }
          return null;
        });

    await service.stopAuthentication();
  });

  test('isSupported returns false on PlatformException', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'error');
        });

    final result = await service.isSupported();

    expect(result, false);
  });

  test('hasEnrolledBiometrics returns false on PlatformException', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'error');
        });

    final result = await service.hasEnrolledBiometrics();

    expect(result, false);
  });

  test('authenticate returns false when unsupported', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'deviceSupportsBiometrics':
              return false;
            case 'isDeviceSupported':
              return false;
          }
          return null;
        });

    final result = await service.authenticate(reason: 'Test authentication');

    expect(result, false);
  });
}
