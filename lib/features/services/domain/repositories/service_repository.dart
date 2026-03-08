import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

abstract interface class IServicesRepository {
  Future<Either<Failure, List<PackageEntity>>> getPackages(String category);
}