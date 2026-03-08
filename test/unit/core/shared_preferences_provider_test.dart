import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';

void main() {
  test('sharedPreferencesProvider throws when not overridden', () {
    final container = ProviderContainer();

    expect(
      () => container.read(sharedPreferencesProvider),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
