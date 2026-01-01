import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/batch/domain/usecases/get_all_batches.dart';
import 'package:wheels_flutter/features/batch/domain/usecases/get_batch_byid.dart';
import '../../domain/usecases/create_batch_usecase.dart';
import '../../domain/usecases/delete_batch_usecase.dart';
import '../../domain/usecases/update_batch_usecase.dart';
import '../state/batch_state.dart';

class BatchViewModel extends StateNotifier<BatchState> {
  final GetAllBatchUsecase _getAllBatchUsecase;
  final GetBatchByIdUsecase _getBatchByIdUsecase;
  final CreateBatchUsecase _createBatchUsecase;
  final UpdateBatchUsecase _updateBatchUsecase;
  final DeleteBatchUsecase _deleteBatchUsecase;

  BatchViewModel({
    required GetAllBatchUsecase getAllBatchUsecase,
    required GetBatchByIdUsecase getBatchByIdUsecase,
    required CreateBatchUsecase createBatchUsecase,
    required UpdateBatchUsecase updateBatchUsecase,
    required DeleteBatchUsecase deleteBatchUsecase,
  }) : _getAllBatchUsecase = getAllBatchUsecase,
       _getBatchByIdUsecase = getBatchByIdUsecase,
       _createBatchUsecase = createBatchUsecase,
       _updateBatchUsecase = updateBatchUsecase,
       _deleteBatchUsecase = deleteBatchUsecase,
       super(const BatchState());

  Future<void> getAllBatches() async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _getAllBatchUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BatchStatus.error,
          errorMessage: failure.message,
        );
      },
      (batches) {
        state = state.copyWith(
          status: BatchStatus.loaded,
          batches: batches,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> getBatchById(String batchId) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _getBatchByIdUsecase.call(
      GetBatchByIdUsecaseParams(batchId: batchId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BatchStatus.error,
          errorMessage: failure.message,
        );
      },
      (batch) {
        // Update state with the found batch
        state = state.copyWith(status: BatchStatus.loaded, errorMessage: null);
      },
    );
  }

  Future<void> createBatch(String batchName) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _createBatchUsecase.call(
      CreateBatchUsecaseParams(batchName: batchName),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(status: BatchStatus.created);
        getAllBatches();
      },
    );
  }

  Future<void> updateBatch({
    required String batchId,
    required String batchName,
    String? status,
  }) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _updateBatchUsecase.call(
      UpdateBatchUsecaseParams(
        batchId: batchId,
        batchName: batchName,
        status: status,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(status: BatchStatus.updated);
        getAllBatches();
      },
    );
  }

  Future<void> deleteBatch(String batchId) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _deleteBatchUsecase.call(
      DeleteBatchUsecaseParams(batchId: batchId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(status: BatchStatus.deleted);
        getAllBatches();
      },
    );
  }
}
