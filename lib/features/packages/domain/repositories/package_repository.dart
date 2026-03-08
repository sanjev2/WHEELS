import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';
import '../../../../core/error/failure.dart';

abstract interface class IPackageRepository {
  Future<Either<Failure, List<PackageEntity>>> getPackages(String category);
}
