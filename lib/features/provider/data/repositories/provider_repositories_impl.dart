import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/provider/data/datasource/remote/provider_remote_datasource.dart';
import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';
import 'package:wheels_flutter/features/provider/domain/repositories/provider_repositories.dart';
import '../../../../core/error/failure.dart';

final providerRepositoryProvider = Provider<IProviderRepository>((ref) {
  return ProviderRepositoryImpl(
    remote: ref.read(providerRemoteDatasourceProvider),
  );
});

class ProviderRepositoryImpl implements IProviderRepository {
  final ProviderRemoteDatasource _remote;

  ProviderRepositoryImpl({required ProviderRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<ProviderEntity>>> getProviders(
    String category,
  ) async {
    try {
      final models = await _remote.getProviders(category: category);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.message ?? "Network error"));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
