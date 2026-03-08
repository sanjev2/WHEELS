import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/services/biometric/biometric_providers.dart';

import '../../test_utils/mocks.dart';

void main() {
  late MockBiometricSecureStore store;
  late MockBiometricService bio;

  setUp(() {
    store = MockBiometricSecureStore();
    bio = MockBiometricService();
  });

  test('enableWithAuth returns false when not supported', () async {
    when(() => store.isEnabled()).thenAnswer((_) async => false);
    when(() => bio.isSupported()).thenAnswer((_) async => false);
    final controller = BiometricEnabledController(store: store, bio: bio);

    final result = await controller.enableWithAuth();

    expect(result, false);
    expect(controller.state, false);
  });

  test('enableWithAuth enables state on success', () async {
    when(() => store.isEnabled()).thenAnswer((_) async => false);
    when(() => bio.isSupported()).thenAnswer((_) async => true);
    when(() => bio.hasEnrolledBiometrics()).thenAnswer((_) async => true);
    when(() => bio.authenticate(reason: any(named: 'reason'))).thenAnswer((_) async => true);
    when(() => store.setEnabled(true)).thenAnswer((_) async {});
    final controller = BiometricEnabledController(store: store, bio: bio);

    final result = await controller.enableWithAuth();

    expect(result, true);
    expect(controller.state, true);
  });
}
