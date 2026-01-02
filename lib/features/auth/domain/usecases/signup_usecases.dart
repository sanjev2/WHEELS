import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';

class SignupParams extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? address;

  const SignupParams({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.address,
  });

  @override
  List<Object?> get props => [fullName, email, password, phoneNumber, address];
}

class SignupUsecase implements UsecaseWithParams<AuthEntity, SignupParams> {
  final IAuthRepository _authRepository;

  SignupUsecase(this._authRepository);

  @override
  Future<Either<Failure, AuthEntity>> call(SignupParams params) async {
    final user = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      address: params.address,
      username: params.email, // Using email as username
      password: params.password,
      isLoggedIn: true,
    );

    return await _authRepository.signup(user);
  }
}
