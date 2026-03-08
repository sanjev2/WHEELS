import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';
import 'package:wheels_flutter/features/provider/domain/repositories/provider_repositories.dart';
import '../../../../core/error/failure.dart';

class GetProvidersUsecase {
  final IProviderRepository repo;

  GetProvidersUsecase({required this.repo});

  Future<Either<Failure, List<ProviderEntity>>> call(String category) {
    return repo.getProviders(category);
  }
}
