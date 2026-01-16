import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/services/hive/hive_services.dart';
import 'package:wheels_flutter/features/batch/data/datasources/batch_datasource.dart';
import 'package:wheels_flutter/features/batch/data/models/batch_hive_model.dart';
import 'package:wheels_flutter/features/batch/domain/entities/batch_entity.dart';

class BatchLocalDatasource implements IBatchDatasource {
  final HiveService _hiveService;

  BatchLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  /// Shortcut to access Hive box
  Box<BatchHiveModel> get _batchBox => _hiveService.batchBox;

  @override
  Future<Either<Failure, List<BatchEntity>>> getAllBatches() async {
    try {
      final batches = _batchBox.values
          .map((hiveModel) => hiveModel.toEntity())
          .toList(growable: false);
      return Right(batches);
    } catch (e, s) {
      debugPrint('[BatchLocalDatasource] Get all batches error: $e\n$s');
      return Left(LocalDatabaseFailure(message: 'Failed to get all batches'));
    }
  }

  @override
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId) async {
    try {
      final hiveModel = _batchBox.get(batchId);
      if (hiveModel == null) {
        return Left(LocalDatabaseFailure(message: 'Batch not found'));
      }
      return Right(hiveModel.toEntity());
    } catch (e, s) {
      debugPrint('[BatchLocalDatasource] Get batch by ID error: $e\n$s');
      return Left(LocalDatabaseFailure(message: 'Failed to get batch'));
    }
  }

  @override
  Future<Either<Failure, bool>> createBatch(BatchEntity batch) async {
    try {
      final hiveModel = BatchHiveModel.fromEntity(batch);
      await _batchBox.put(hiveModel.batchId, hiveModel);
      return const Right(true);
    } catch (e, s) {
      debugPrint('[BatchLocalDatasource] Create batch error: $e\n$s');
      return Left(LocalDatabaseFailure(message: 'Failed to create batch'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBatch(BatchEntity batch) async {
    try {
      if (!_batchBox.containsKey(batch.batchId)) {
        return Left(LocalDatabaseFailure(message: 'Batch not found'));
      }
      final hiveModel = BatchHiveModel.fromEntity(batch);
      await _batchBox.put(hiveModel.batchId, hiveModel);
      return const Right(true);
    } catch (e, s) {
      debugPrint('[BatchLocalDatasource] Update batch error: $e\n$s');
      return Left(LocalDatabaseFailure(message: 'Failed to update batch'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBatch(String batchId) async {
    try {
      if (!_batchBox.containsKey(batchId)) {
        return Left(LocalDatabaseFailure(message: 'Batch not found'));
      }
      await _batchBox.delete(batchId);
      return const Right(true);
    } catch (e, s) {
      debugPrint('[BatchLocalDatasource] Delete batch error: $e\n$s');
      return Left(LocalDatabaseFailure(message: 'Failed to delete batch'));
    }
  }
}
