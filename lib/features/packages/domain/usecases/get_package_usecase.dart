import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';
import '../../../../core/error/failure.dart';
import '../repositories/package_repository.dart';

class GetPackagesUsecase {
  final IPackageRepository repo;

  GetPackagesUsecase({required this.repo});

  Future<Either<Failure, List<PackageEntity>>> call(String category) {
    return repo.getPackages(category);
  }
}
