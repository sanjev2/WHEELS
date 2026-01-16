// features/auth/domain/usecases/register_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String contact;
  final String address;
  final String role; // ← add this

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.contact,
    required this.address,
    this.role = "user", // default
  });

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    confirmPassword,
    contact,
    address,
    role, // ← include role
  ];
}

class RegisterUsecase implements UsecaseWithParams<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    final entity = AuthEntity(
      userId: null,
      name: params.name,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
      contact: params.contact,
      address: params.address,
      isLoggedIn: false,
      role: params.role, // ← now dynamic
    );

    return _authRepository.register(entity);
  }
}
