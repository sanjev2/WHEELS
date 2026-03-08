import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:wheels_flutter/features/auth/presentation/view_model/auth_view_model.dart';

import 'package:wheels_flutter/features/auth/data/repositories/auth_repository.dart';

import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/get_current_users.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/is_login_usecase.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/logout_usecase.dart';

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUsecase(authRepository: repo);
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository: repo);
});

final isLoggedInUsecaseProvider = Provider<IsLoggedInUsecase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return IsLoggedInUsecase(authRepository: repo);
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LogoutUsecase(authRepository: repo);
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(
    loginUsecase: ref.watch(loginUsecaseProvider),
    registerUsecase: ref.watch(registerUsecaseProvider),
    getCurrentUserUsecase: ref.watch(getCurrentUserUsecaseProvider),
    isLoggedInUsecase: ref.watch(isLoggedInUsecaseProvider),
    logoutUsecase: ref.watch(logoutUsecaseProvider),
  );
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authViewModelProvider).status;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authViewModelProvider).status == AuthStatus.loading;
});

final currentUserProvider = Provider((ref) {
  return ref.watch(authViewModelProvider).authEntity;
});

final currentUserIdProvider = Provider<String?>((ref) {
  final s = ref.watch(authViewModelProvider);
  return s.authEntity?.userId;
});
