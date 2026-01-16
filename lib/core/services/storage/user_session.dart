// core/services/storage/user_session.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferenceProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final sharedPreferencesFuture = ref.watch(sharedPreferenceProvider);

  // This will throw if SharedPreferences is not ready
  // In your main.dart, you should await SharedPreferences before running app
  if (sharedPreferencesFuture.hasValue &&
      sharedPreferencesFuture.value != null) {
    return UserSessionService(
      sharedPreferences: sharedPreferencesFuture.value!,
    );
  }

  throw Exception('SharedPreferences not initialized');
});

class UserSessionService {
  final SharedPreferences _sharedPreferences;

  UserSessionService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  // Keys
  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyUserId = "user_id";
  static const String _keyUserEmail = "user_email";
  static const String _keyUserName = "user_name";
  static const String _keyUserContact = "user_contact";
  static const String _keyUserAddress = "user_address";

  // Save user session
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String name,
    required String contact,
    required String address,
  }) async {
    await _sharedPreferences.setBool(_keyIsLoggedIn, true);
    await _sharedPreferences.setString(_keyUserId, userId);
    await _sharedPreferences.setString(_keyUserEmail, email);
    await _sharedPreferences.setString(_keyUserName, name);
    await _sharedPreferences.setString(_keyUserContact, contact);
    await _sharedPreferences.setString(_keyUserAddress, address);
  }

  // Clear session (logout)
  Future<void> clearSession() async {
    await _sharedPreferences.remove(_keyIsLoggedIn);
    await _sharedPreferences.remove(_keyUserId);
    await _sharedPreferences.remove(_keyUserEmail);
    await _sharedPreferences.remove(_keyUserName);
    await _sharedPreferences.remove(_keyUserContact);
    await _sharedPreferences.remove(_keyUserAddress);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _sharedPreferences.getBool(_keyIsLoggedIn) ?? false;
  }

  // Getters
  String? getUserId() => _sharedPreferences.getString(_keyUserId);
  String? getEmail() => _sharedPreferences.getString(_keyUserEmail);
  String? getName() => _sharedPreferences.getString(_keyUserName);
  String? getContact() => _sharedPreferences.getString(_keyUserContact);
  String? getAddress() => _sharedPreferences.getString(_keyUserAddress);

  // Get all user data
  Map<String, String?> getUserData() {
    return {
      'userId': getUserId(),
      'email': getEmail(),
      'name': getName(),
      'contact': getContact(),
      'address': getAddress(),
    };
  }
}
