import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  SharedPrefsHelper(this._prefs);

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

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
  }

  Map<String, String?> getUserData() {
    return {
      'token': _prefs.getString(_tokenKey),
      'userId': _prefs.getString(_userIdKey),
      'email': _prefs.getString(_userEmailKey),
      'name': _prefs.getString(_userNameKey),
    };
  }
}
