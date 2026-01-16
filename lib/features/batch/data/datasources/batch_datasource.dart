import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/batch/domain/entities/batch_entity.dart';

abstract class IBatchDatasource {
  Future<Either<Failure, List<BatchEntity>>> getAllBatches();
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId);
  Future<Either<Failure, bool>> createBatch(BatchEntity batch);
  Future<Either<Failure, bool>> updateBatch(BatchEntity batch);
  Future<Either<Failure, bool>> deleteBatch(String batchId);
}

//
