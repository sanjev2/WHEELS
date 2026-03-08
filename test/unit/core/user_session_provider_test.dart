import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';

void main() {
  test('userSessionServiceProvider returns UserSessionService', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    final service = container.read(userSessionServiceProvider);

    expect(service, isA<UserSessionService>());
  });
}
