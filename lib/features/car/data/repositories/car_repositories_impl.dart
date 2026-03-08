import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/features/car/data/datasource/local/car_local_datasource.dart';
import 'package:wheels_flutter/features/car/data/datasource/remote/car_remote_datasource.dart';
import 'package:wheels_flutter/features/car/data/models/car_api_model.dart';
import 'package:wheels_flutter/features/car/data/models/car_hive_model.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/services/connectivity/network_info.dart';

import '../../../car/domain/entities/car_entity.dart';
import '../../../car/domain/repositories/car_repository.dart';

import '../../../car/data/datasource/car_datasource.dart';

final carRepositoryProvider = Provider<ICarRepository>((ref) {
  return CarRepositoryImpl(
    localDatasource: ref.read(carLocalDatasourceProvider),
    remoteDatasource: ref.read(carRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CarRepositoryImpl implements ICarRepository {
  final ICarDatasource _localDatasource;
  final ICarRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  CarRepositoryImpl({
    required ICarDatasource localDatasource,
    required ICarRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<CarEntity>>> getMyCars() async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteCars = await _remoteDatasource.getMyCars();

        for (final c in remoteCars) {
          await _localDatasource.addCar(CarHiveModel.fromEntity(c.toEntity()));
        }

        return Right(remoteCars.map((e) => e.toEntity()).toList());
      }

      final local = await _localDatasource.getMyCars();
      return Right(local.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data?["message"] ?? e.message ?? "Network error",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> addCar(CarEntity car) async {
    try {
      if (await _networkInfo.isConnected) {
        final created = await _remoteDatasource.addCar(
          CarApiModel.fromEntity(car),
        );
        await _localDatasource.addCar(
          CarHiveModel.fromEntity(created.toEntity()),
        );
        return Right(created.toEntity());
      }

      final saved = await _localDatasource.addCar(CarHiveModel.fromEntity(car));
      return Right(saved.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCar(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDatasource.deleteCar(id);
      }
      await _localDatasource.deleteCar(id);
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> updateCar(String id, CarEntity car) async {
    try {
      if (await _networkInfo.isConnected) {
        final updated = await _remoteDatasource.updateCar(
          id,
          CarApiModel.fromEntity(car),
        );

        await _localDatasource.addCar(
          CarHiveModel.fromEntity(updated.toEntity()),
        );

        return Right(updated.toEntity());
      }

      // offline: update local only (best effort)
      await _localDatasource.addCar(CarHiveModel.fromEntity(car));
      return Right(car);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
