import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';

class LogoutUsecase implements UsecaseWithoutParams<void> {
  final IAuthRepository _repo;
  LogoutUsecase({required IAuthRepository authRepository})
    : _repo = authRepository;

  @override
  Future<Either<Failure, void>> call() {
    return _repo.logout();
  }
}
