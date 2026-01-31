import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';

/// A tiny fake notifier to keep widget tests stable.
/// It mimics your UI contract: login/register update AuthState.
class FakeAuthViewModel extends StateNotifier<AuthState> {
  FakeAuthViewModel([AuthState? initial])
    : super(initial ?? const AuthState(status: AuthStatus.initial));

  Future<void> login({required String email, required String password}) async {
    state = const AuthState(status: AuthStatus.loading);

    // Instant "success" rule for testing
    if (email.trim().isNotEmpty && password.isNotEmpty) {
      state = const AuthState(status: AuthStatus.authenticated);
    } else {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Invalid credentials',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String contact,
    required String address,
  }) async {
    state = const AuthState(status: AuthStatus.loading);

    if (name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        password.isNotEmpty &&
        contact.trim().isNotEmpty &&
        address.trim().isNotEmpty) {
      state = const AuthState(status: AuthStatus.registered);
    } else {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Invalid signup details',
      );
    }
  }

  void setState(AuthState s) => state = s;
}
