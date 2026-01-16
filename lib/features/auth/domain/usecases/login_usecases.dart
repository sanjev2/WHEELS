// features/auth/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
