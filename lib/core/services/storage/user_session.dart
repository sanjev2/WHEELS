import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserSessionService(sharedPreferences: prefs);
});

class UserSessionService {
  final SharedPreferences _sharedPreferences;

  UserSessionService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyUserId = "user_id";
  static const String _keyUserEmail = "user_email";
  static const String _keyUserName = "user_name";
  static const String _keyUserContact = "user_contact";
  static const String _keyUserAddress = "user_address";
  static const String _keyProfilePicture = "profile_picture";

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String name,
    required String contact,
    required String address,
    String? profilePicture,
  }) async {
    await _sharedPreferences.setBool(_keyIsLoggedIn, true);
    await _sharedPreferences.setString(_keyUserId, userId);
    await _sharedPreferences.setString(_keyUserEmail, email);
    await _sharedPreferences.setString(_keyUserName, name);
    await _sharedPreferences.setString(_keyUserContact, contact);
    await _sharedPreferences.setString(_keyUserAddress, address);

    if (profilePicture != null && profilePicture.isNotEmpty) {
      await _sharedPreferences.setString(_keyProfilePicture, profilePicture);
    } else {
      await _sharedPreferences.remove(_keyProfilePicture);
    }
  }

  Future<void> saveProfilePicture(String filename) async {
    await _sharedPreferences.setString(_keyProfilePicture, filename);
  }

  Future<void> clearSession() async {
    await _sharedPreferences.remove(_keyIsLoggedIn);
    await _sharedPreferences.remove(_keyUserId);
    await _sharedPreferences.remove(_keyUserEmail);
    await _sharedPreferences.remove(_keyUserName);
    await _sharedPreferences.remove(_keyUserContact);
    await _sharedPreferences.remove(_keyUserAddress);
    await _sharedPreferences.remove(_keyProfilePicture);
  }

  bool isLoggedIn() {
    final ok = _sharedPreferences.getBool(_keyIsLoggedIn) ?? false;
    final id = _sharedPreferences.getString(_keyUserId);
    return ok && id != null && id.isNotEmpty;
  }

  String? getUserId() => _sharedPreferences.getString(_keyUserId);
  String? getEmail() => _sharedPreferences.getString(_keyUserEmail);
  String? getName() => _sharedPreferences.getString(_keyUserName);
  String? getContact() => _sharedPreferences.getString(_keyUserContact);
  String? getAddress() => _sharedPreferences.getString(_keyUserAddress);
  String? getProfilePicture() =>
      _sharedPreferences.getString(_keyProfilePicture);

  Map<String, String?> getUserData() => {
    'userId': getUserId(),
    'email': getEmail(),
    'name': getName(),
    'contact': getContact(),
    'address': getAddress(),
    'profilePicture': getProfilePicture(),
  };
}
