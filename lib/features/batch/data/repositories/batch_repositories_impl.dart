import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/batch_entity.dart';
import '../../domain/repositories/batch_repository.dart';
import '../datasources/batch_datasource.dart';
import '../models/batch_hive_model.dart';

class BatchRepositoryImpl implements IBatchRepository {
  final IBatchDatasource _datasource;

  BatchRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<BatchEntity>>> getAllBatches() async {
    try {
      final models = await _datasource.getAllBatches();
      final entities = BatchHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to get batches: $e'));
    }
  }

  @override
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId) async {
    try {
      final model = await _datasource.getBatchById(batchId);
      if (model != null) {
        return Right(model.toEntity());
      } else {
        return Left(LocalDatabaseFailure(message: 'Batch not found'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to get batch: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> createBatch(BatchEntity batch) async {
    try {
      final model = BatchHiveModel.fromEntity(batch);
      final result = await _datasource.createBatch(model);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: 'Failed to create batch'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to create batch: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBatch(BatchEntity batch) async {
    try {
      final model = BatchHiveModel.fromEntity(batch);
      final result = await _datasource.updateBatch(model);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: 'Failed to update batch'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to update batch: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBatch(String batchId) async {
    try {
      final result = await _datasource.deleteBatch(batchId);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: 'Failed to delete batch'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: 'Failed to delete batch: $e'));
    }
  }
}
