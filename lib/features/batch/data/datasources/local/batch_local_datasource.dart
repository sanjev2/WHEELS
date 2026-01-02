import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:wheels_flutter/core/services/hive/hive_services.dart';
import 'package:wheels_flutter/features/batch/data/models/batch_hive_model.dart';
import '../batch_datasource.dart';

class BatchLocalDatasource implements IBatchDatasource {
  final HiveService _hiveService;

  BatchLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  Box<BatchHiveModel> get _batchBox => _hiveService.batchBox;

  @override
  Future<bool> createBatch(BatchHiveModel batch) async {
    try {
      await _batchBox.put(batch.batchId, batch);
      return true;
    } catch (e, s) {
      debugPrint('Create batch error: $e\n$s');
      return false;
    }
  }

  @override
  Future<bool> deleteBatch(String batchId) async {
    try {
      await _batchBox.delete(batchId);
      return true;
    } catch (e, s) {
      debugPrint('Delete batch error: $e\n$s');
      return false;
    }
  }

  @override
  Future<List<BatchHiveModel>> getAllBatches() async {
    try {
      return _batchBox.values.toList(growable: false);
    } catch (e, s) {
      debugPrint('Get all batches error: $e\n$s');
      return [];
    }
  }

  @override
  Future<BatchHiveModel?> getBatchById(String batchId) async {
    try {
      return _batchBox.get(batchId);
    } catch (e, s) {
      debugPrint('Get batch by ID error: $e\n$s');
      return null;
    }
  }

  @override
  Future<bool> updateBatch(BatchHiveModel batch) async {
    try {
      await _batchBox.put(batch.batchId, batch);
      return true;
    } catch (e, s) {
      debugPrint('Update batch error: $e\n$s');
      return false;
    }
  }
}
