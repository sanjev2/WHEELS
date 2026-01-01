import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? user;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isAuthenticated];
}
