import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/packages/data/remote/package_remote_datasource.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/package_repository.dart';

final packageRepositoryProvider = Provider<IPackageRepository>((ref) {
  return PackageRepositoryImpl(
    remote: ref.read(packageRemoteDatasourceProvider),
  );
});

class PackageRepositoryImpl implements IPackageRepository {
  final PackageRemoteDatasource _remote;

  PackageRepositoryImpl({required PackageRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<PackageEntity>>> getPackages(
    String category,
  ) async {
    try {
      final models = await _remote.getPackages(category: category);
      final entities = models
          .map((m) => m.toEntity())
          .where((e) => e.isActive)
          .toList();
      return Right(entities);
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.message ?? "Network error"));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
