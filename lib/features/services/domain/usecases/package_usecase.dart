import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';
import 'package:wheels_flutter/features/services/domain/repositories/service_repository.dart';

class GetPackagesUsecase
    implements UsecaseWithParams<List<PackageEntity>, String> {
  final IServicesRepository _repo;

  GetPackagesUsecase({required IServicesRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, List<PackageEntity>>> call(String category) {
    return _repo.getPackages(category);
  }
}
