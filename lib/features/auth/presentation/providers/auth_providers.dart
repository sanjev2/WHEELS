import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:wheels_flutter/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../view_model/auth_view_model.dart';
import '../state/auth_state.dart';

// ========== AUTH DATA SOURCE ==========
final authDataSourceProvider = Provider<IAuthDatasource>((ref) {
  return AuthLocalDatasource();
});

// ========== AUTH REPOSITORY ==========
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dataSource = ref.read(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// ========== AUTH USE CASES ==========
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUsecase(repository);
});

final signupUsecaseProvider = Provider<SignupUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignupUsecase(repository);
});

// ========== AUTH VIEW MODEL ==========
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(
    loginUsecase: ref.read(loginUsecaseProvider),
    signupUsecase: ref.read(signupUsecaseProvider),
  );
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authViewModelProvider).status;
});

final currentUserProvider = Provider<AuthEntity?>((ref) {
  return ref.watch(authViewModelProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authViewModelProvider).isAuthenticated;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authViewModelProvider).errorMessage;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authViewModelProvider).status == AuthStatus.loading;
});
