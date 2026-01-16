import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  final SharedPreferences _prefs;

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  // Constructor receives already-initialized SharedPreferences
  SharedPrefsHelper(this._prefs);

  // Save user session after login
  Future<void> saveUserSession({
    required String token,
    required String userId,
    required String email,
    required String name,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userNameKey, name);
  }

  // Get saved token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // Get user ID
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
  }

  // Get user details
  Map<String, String?> getUserData() {
    return {
      'token': _prefs.getString(_tokenKey),
      'userId': _prefs.getString(_userIdKey),
      'email': _prefs.getString(_userEmailKey),
      'name': _prefs.getString(_userNameKey),
    };
  }
}
