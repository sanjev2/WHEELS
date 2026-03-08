import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/services/connectivity/network_info.dart';

import 'package:wheels_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:wheels_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';

import 'package:wheels_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:wheels_flutter/features/auth/data/models/auth_hive_model.dart';

import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDatasource: ref.read(authLocalDatasourceProvider),
    remoteDatasource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDatasource _localDatasource;
  final IAuthRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required IAuthDatasource localDatasource,
    required IAuthRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      if (await _networkInfo.isConnected) {
        final apiUser = await _remoteDatasource.login(email, password);
        if (apiUser != null) return Right(apiUser.toEntity());
        return Left(AuthFailure(message: "Invalid email or password"));
      }

      final localUser = await _localDatasource.login(email, password);
      if (localUser != null) return Right(localUser.toEntity());

      return Left(AuthFailure(message: "Invalid email or password"));
    } on DioException catch (e) {
      return Left(AuthFailure(message: _extractDioError(e)));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      if (await _networkInfo.isConnected) {
        final apiModel = AuthApiModel.fromEntity(entity);
        final created = await _remoteDatasource.register(apiModel);

        if (created.authId != null && created.authId!.isNotEmpty) {
          return const Right(true);
        }
        return Left(AuthFailure(message: "Registration failed on backend"));
      }

      // offline: hive
      final hiveModel = AuthHiveModel.fromEntity(entity);
      await _localDatasource.signup(hiveModel);
      return const Right(true);
    } on DioException catch (e) {
      return Left(AuthFailure(message: _extractDioError(e)));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      final ok = await _localDatasource.isUserLoggedIn();
      return Right(ok);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _localDatasource.getCurrentUser();
      if (user != null) return Right(user.toEntity());
      return Left(AuthFailure(message: "No user found"));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDatasource.logout();
      await _remoteDatasource.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: "Logout failed: $e"));
    }
  }

  String _extractDioError(DioException e) {
    if (e.response?.data == null) return "Network error. Please try again.";
    final data = e.response!.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
    }
    return e.message ?? "Something went wrong";
  }
}
