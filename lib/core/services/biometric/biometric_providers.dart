import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wheels_flutter/core/services/biometric/biometric_credential_store.dart';

import 'biometric_service.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final biometricSecureStoreProvider = Provider<BiometricSecureStore>((ref) {
  final storage = ref.read(flutterSecureStorageProvider);
  return BiometricSecureStore(storage);
});

final biometricEnabledProvider =
    StateNotifierProvider<BiometricEnabledController, bool>((ref) {
      final store = ref.read(biometricSecureStoreProvider);
      final bio = ref.read(biometricServiceProvider);
      return BiometricEnabledController(store: store, bio: bio);
    });

final biometricCredentialControllerProvider =
    StateNotifierProvider<BiometricCredentialController, bool>((ref) {
      final store = ref.read(biometricSecureStoreProvider);
      return BiometricCredentialController(store);
    });

final biometricCredentialDataProvider = FutureProvider<Map<String, String?>>((
  ref,
) async {
  final store = ref.read(biometricSecureStoreProvider);
  return store.readCredentials();
});

class BiometricEnabledController extends StateNotifier<bool> {
  BiometricEnabledController({required this.store, required this.bio})
    : super(false) {
    _init();
  }

  final BiometricSecureStore store;
  final BiometricService bio;

  Future<void> _init() async {
    state = await store.isEnabled();
  }

  Future<bool> enableWithAuth() async {
    final supported = await bio.isSupported();
    if (!supported) return false;

    final enrolled = await bio.hasEnrolledBiometrics();
    if (!enrolled) return false;

    final ok = await bio.authenticate(reason: 'Enable Face/Fingerprint unlock');
    if (!ok) return false;

    await store.setEnabled(true);
    state = true;
    return true;
  }

  Future<void> disable() async {
    await store.setEnabled(false);
    state = false;
  }

  Future<void> refresh() async {
    state = await store.isEnabled();
  }
}

class BiometricCredentialController extends StateNotifier<bool> {
  BiometricCredentialController(this._store) : super(false) {
    _init();
  }

  final BiometricSecureStore _store;

  Future<void> _init() async {
    state = await _store.hasCredentials();
  }

  Future<void> save({required String email, required String password}) async {
    await _store.saveCredentials(email: email, password: password);
    state = await _store.hasCredentials();
  }

  Future<void> clear() async {
    await _store.clearCredentials();
    state = await _store.hasCredentials();
  }

  Future<Map<String, String?>> authenticateAndRead(BiometricService bio) async {
    final ok = await bio.authenticate(
      reason: 'Authenticate to use saved login credentials',
    );

    if (!ok) {
      return {'email': null, 'password': null};
    }

    return _store.readCredentials();
  }

  Future<void> refresh() async {
    state = await _store.hasCredentials();
  }

  Future<bool> hasCredentialsDirect() async {
    return _store.hasCredentials();
  }
}
