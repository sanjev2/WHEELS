import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/onboarding_storage.dart';

void main() {
  late SharedPreferences prefs;
  late OnboardingStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = OnboardingStorage(prefs);
  });

  test('hasSeen is false initially', () {
    expect(storage.hasSeen(), false);
  });

  test('markSeen sets hasSeen to true', () async {
    await storage.markSeen();

    expect(storage.hasSeen(), true);
  });
}
