import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_entity.dart';
import '../datasources/auth_datasource.dart';
import '../models/auth_hive_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _datasource.login(email, password);
      if (user != null) {
        return Right(user.toEntity());
      } else {
        return Left(AuthFailure(message: 'Invalid email or password'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> signup(AuthEntity entity) async {
    try {
      final userModel = AuthHiveModel.fromEntity(entity);
      final user = await _datasource.signup(userModel);
      return Right(user.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Signup failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _datasource.logout();
      return const Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> getCurrentUser() async {
    try {
      final user = await _datasource.getCurrentUser();
      return Right(user?.toEntity());
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: 'Failed to get current user: $e'),
      );
    }
  }
}
