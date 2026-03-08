import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';
import '../../../../core/error/failure.dart';

abstract interface class IProviderRepository {
  Future<Either<Failure, List<ProviderEntity>>> getProviders(String category);
}
