import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/batch/data/datasources/batch_datasource.dart';
import 'package:wheels_flutter/features/batch/domain/entities/batch_entity.dart';
import 'package:wheels_flutter/features/batch/domain/repositories/batch_repository.dart';

class BatchRepositoryImpl implements IBatchRepository {
  final IBatchDatasource _dataSource;

  BatchRepositoryImpl({required IBatchDatasource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<BatchEntity>>> getAllBatches() {
    return _dataSource.getAllBatches();
  }

  @override
  Future<Either<Failure, bool>> createBatch(BatchEntity batch) {
    return _dataSource.createBatch(batch);
  }

  @override
  Future<Either<Failure, bool>> deleteBatch(String batchId) {
    return _dataSource.deleteBatch(batchId);
  }

  @override
  Future<Either<Failure, BatchEntity>> getBatchById(String id) {
    return _dataSource.getBatchById(id);
  }

  @override
  Future<Either<Failure, bool>> updateBatch(BatchEntity batch) {
    return _dataSource.updateBatch(batch);
  }
}
