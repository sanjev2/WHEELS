import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/get_current_users.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/is_login_usecase.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final GetCurrentUserUsecase _getCurrentUserUsecase;
  final IsLoggedInUsecase _isLoggedInUsecase;
  final LogoutUsecase _logoutUsecase;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required GetCurrentUserUsecase getCurrentUserUsecase,
    required IsLoggedInUsecase isLoggedInUsecase,
    required LogoutUsecase logoutUsecase,
  }) : _loginUsecase = loginUsecase,
       _registerUsecase = registerUsecase,
       _getCurrentUserUsecase = getCurrentUserUsecase,
       _isLoggedInUsecase = isLoggedInUsecase,
       _logoutUsecase = logoutUsecase,
       super(const AuthState());

  Future<void> init() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final loggedInEither = await _isLoggedInUsecase();

    await loggedInEither.fold(
      (f) async {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          authEntity: null,
          errorMessage: f.message,
        );
      },
      (loggedIn) async {
        if (!loggedIn) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            authEntity: null,
            errorMessage: null,
          );
          return;
        }

        final userEither = await _getCurrentUserUsecase();

        userEither.fold(
          (failure) {
            state = state.copyWith(
              status: AuthStatus.unauthenticated,
              authEntity: null,
              errorMessage: failure.message,
            );
          },
          (user) {
            state = state.copyWith(
              status: AuthStatus.authenticated,
              authEntity: user,
              errorMessage: null,
            );
          },
        );
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      authEntity: null,
    );

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          authEntity: null,
        );
      },
      (_) async {
        await init();
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String contact,
    required String address,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

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
        state = success
            ? state.copyWith(status: AuthStatus.registered, errorMessage: null)
            : state.copyWith(
                status: AuthStatus.error,
                errorMessage: 'Registration failed',
              );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _logoutUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          authEntity: null,
          errorMessage: null,
        );
      },
    );
  }
}
