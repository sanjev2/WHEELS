// features/auth/presentation/view_model/auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
  }) : _loginUsecase = loginUsecase,
       _registerUsecase = registerUsecase,
       super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final result = await _loginUsecase(
        LoginParams(email: email, password: password),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
        },
        (authEntity) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authEntity: authEntity,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
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
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final result = await _registerUsecase(
        RegisterParams(
          name: name,
          email: email,
          password: password,
          confirmPassword: password,
          contact: contact,
          address: address,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
        },
        (success) {
          if (success) {
            state = state.copyWith(
              status: AuthStatus.registered,
              errorMessage: null,
            );
          } else {
            state = state.copyWith(
              status: AuthStatus.error,
              errorMessage: "Registration failed",
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      authEntity: null,
      errorMessage: null,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
