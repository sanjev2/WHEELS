import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

class GetCurrentUserUsecase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _authRepository.getCurrentUser();
  }
}
