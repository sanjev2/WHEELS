import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginParams> {
  final IAuthRepository _authReository;

  LoginUsecase(this._authRepository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    return await _authRepository.login(params.email, params.password);
  }
}
