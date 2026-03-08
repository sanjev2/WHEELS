import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/onboarding_storage.dart';
import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';

void main() {
  test('onboardingStorageProvider returns OnboardingStorage', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    final storage = container.read(onboardingStorageProvider);

    expect(storage, isA<OnboardingStorage>());
  });
}
