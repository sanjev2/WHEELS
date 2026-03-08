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

  test('save persists credentials and updates state', () async {
    when(() => store.hasCredentials()).thenAnswer((_) async => true);
    when(() => store.saveCredentials(email: any(named: 'email'), password: any(named: 'password'))).thenAnswer((_) async {});
    final controller = BiometricCredentialController(store);

    await controller.save(email: 'a@b.com', password: '123456');

    expect(controller.state, true);
  });

  test('authenticateAndRead returns null map when auth fails', () async {
    when(() => store.hasCredentials()).thenAnswer((_) async => false);
    when(() => bio.authenticate(reason: any(named: 'reason'))).thenAnswer((_) async => false);
    final controller = BiometricCredentialController(store);

    final result = await controller.authenticateAndRead(bio);

    expect(result['email'], isNull);
    expect(result['password'], isNull);
  });
}
