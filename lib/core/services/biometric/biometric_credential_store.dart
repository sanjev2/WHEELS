import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricSecureStore {
  BiometricSecureStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _kEmail = 'bio_login_email';
  static const _kPassword = 'bio_login_password';
  static const _kEnabled = 'biometric_login_autofill_enabled';

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _kEmail, value: email);
    await _storage.write(key: _kPassword, value: password);
  }

  Future<Map<String, String?>> readCredentials() async {
    final email = await _storage.read(key: _kEmail);
    final password = await _storage.read(key: _kPassword);

    return {'email': email, 'password': password};
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _kEmail);
    await _storage.delete(key: _kPassword);
  }

  Future<bool> hasCredentials() async {
    final email = await _storage.read(key: _kEmail);
    final password = await _storage.read(key: _kPassword);

    return (email != null && email.isNotEmpty) &&
        (password != null && password.isNotEmpty);
  }

  Future<bool> isEnabled() async {
    final value = await _storage.read(key: _kEnabled);
    return value == 'true';
  }

  Future<void> setEnabled(bool value) async {
    await _storage.write(key: _kEnabled, value: value ? 'true' : 'false');
  }

  Future<void> clearAllBiometricData() async {
    await clearCredentials();
    await _storage.delete(key: _kEnabled);
  }
}
