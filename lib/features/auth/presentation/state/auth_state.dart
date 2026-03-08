import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
}

const _unset = Object();

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Object? authEntity = _unset,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity == _unset
          ? this.authEntity
          : authEntity as AuthEntity?,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}
