import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingStorage(prefs);
});

class OnboardingStorage {
  final SharedPreferences _prefs;
  OnboardingStorage(this._prefs);

  static const _key = 'has_seen_onboarding';

  bool hasSeen() => _prefs.getBool(_key) ?? false;

  Future<void> markSeen() async {
    await _prefs.setBool(_key, true);
  }
}
