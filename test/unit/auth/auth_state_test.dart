import 'package:flutter_test/flutter_test.dart';

import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';

import '../../test_utils/mocks.dart';

void main() {
  test('default state is initial', () {
    expect(const AuthState().status, AuthStatus.initial);
  });

  test('copyWith can clear authEntity explicitly', () {
    final state = AuthState(status: AuthStatus.authenticated, authEntity: makeAuthEntity());
    final cleared = state.copyWith(authEntity: null);

    expect(cleared.authEntity, isNull);
    expect(cleared.status, AuthStatus.authenticated);
  });
}
