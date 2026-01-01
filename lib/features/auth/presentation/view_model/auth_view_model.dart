import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';
import '../state/auth_state.dart';
import '../providers/auth_providers.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final SignupUsecase _signupUsecase;

  AuthViewModel({
    required LoginUsecase loginUsecase,
    required SignupUsecase signupUsecase,
  }) : _loginUsecase = loginUsecase,
       _signupUsecase = signupUsecase,
       super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _loginUsecase.call(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          isAuthenticated: false,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.success,
          user: user,
          isAuthenticated: true,
          errorMessage: null,
        );
      },
    );
  }

  // In the AuthViewModel class, update the signup method:

  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? address,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _signupUsecase.call(
      SignupParams(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        address: address,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          isAuthenticated: false,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.success,
          user: user,
          isAuthenticated: true,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.initial,
      user: null,
      isAuthenticated: false,
      errorMessage: null,
    );
  }

  // Helper method to check if user is logged in
  bool get isLoggedIn => state.isAuthenticated;

  // Get current user
  AuthEntity? get currentUser => state.user;
}

// Auth ViewModel Provider using the separate auth providers
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(
    loginUsecase: ref.read(loginUsecaseProvider),
    signupUsecase: ref.read(signupUsecaseProvider),
  );
});
