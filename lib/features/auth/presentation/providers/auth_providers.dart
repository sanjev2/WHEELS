// features/auth/presentation/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:wheels_flutter/features/auth/presentation/view_model/auth_view_model.dart';

// ========== AUTH USE CASES ==========
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

// ========== AUTH VIEW MODEL ==========
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    loginUsecase: ref.read(loginUsecaseProvider),
    registerUsecase: ref.read(registerUsecaseProvider),
  ),
);

// ========== DERIVED PROVIDERS ==========
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authViewModelProvider).status;
});

final currentUserProvider = Provider<AuthEntity?>((ref) {
  return ref.watch(authViewModelProvider).authEntity;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authViewModelProvider).errorMessage;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authViewModelProvider).status == AuthStatus.loading;
});

// ========== CURRENT USER DETAILS ==========
final currentUserNameProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.name;
});

final currentUserEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email;
});

final currentUserContactProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.contact;
});

final currentUserAddressProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.address;
});
