// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';

// final biometricPrefsProvider = Provider<BiometricPrefs>((ref) {
//   final prefs = ref.watch(sharedPreferencesProvider);
//   return BiometricPrefs(prefs);
// });

// class BiometricPrefs {
//   BiometricPrefs(this._prefs);

//   final SharedPreferences _prefs;

//   static const _key = "biometric_login_autofill_enabled";

//   bool get enabled => _prefs.getBool(_key) ?? false;

//   Future<void> setEnabled(bool value) async {
//     await _prefs.setBool(_key, value);
//   }
// }
