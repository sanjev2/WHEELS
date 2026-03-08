import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage_provider.dart';
import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';

void main() {
  test('activeCarStorageProvider returns ActiveCarStorage', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    final storage = container.read(activeCarStorageProvider);

    expect(storage, isA<ActiveCarStorage>());
  });
}
