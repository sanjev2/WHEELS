import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';

class IsLoggedInUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _repo;
  IsLoggedInUsecase({required IAuthRepository authRepository})
    : _repo = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _repo.isUserLoggedIn();
  }
}
