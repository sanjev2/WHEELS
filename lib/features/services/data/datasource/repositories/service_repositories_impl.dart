import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/services/data/datasource/remote/service_remote_datasource.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';
import 'package:wheels_flutter/features/services/domain/repositories/service_repository.dart';

final servicesRepositoryProvider = Provider<IServicesRepository>((ref) {
  return ServicesRepositoryImpl(
    remote: ref.read(servicesRemoteDatasourceProvider),
  );
});

class ServicesRepositoryImpl implements IServicesRepository {
  final IServicesRemoteDatasource _remote;

  ServicesRepositoryImpl({required IServicesRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<PackageEntity>>> getPackages(
    String category,
  ) async {
    try {
      final apiList = await _remote.getPackages(category: category);
      final entities = apiList
          .map((m) => m.toEntity())
          .where((p) => p.isActive)
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
