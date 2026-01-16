import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/batch/domain/entities/batch_entity.dart';
import 'package:wheels_flutter/features/batch/domain/repositories/batch_repository.dart';
import 'package:wheels_flutter/features/batch/presentation/providers/batch_provider.dart';
import 'package:wheels_flutter/features/batch/presentation/state/batch_state.dart';

final batchViewModelProvider = NotifierProvider<BatchViewModel, BatchState>(
  () => BatchViewModel(),
);

class BatchViewModel extends Notifier<BatchState> {
  late final IBatchRepository _batchRepository;

  @override
  BatchState build() {
    // Get the repository from the provider
    _batchRepository = ref.read(batchRepositoryProvider);
    return BatchState();
  }

  Future<void> getAllBatches() async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _batchRepository.getAllBatches();

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

  Future<void> createBatch(String batchName) async {
    state = state.copyWith(status: BatchStatus.loading);

    final batch = BatchEntity(batchName: batchName);
    final result = await _batchRepository.createBatch(batch);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BatchStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        if (success) {
          state = state.copyWith(status: BatchStatus.created);
          getAllBatches(); // Refresh the list
        }
      },
    );
  }

  Future<void> deleteBatch(String batchId) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _batchRepository.deleteBatch(batchId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BatchStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        if (success) {
          state = state.copyWith(status: BatchStatus.deleted);
          getAllBatches(); // Refresh the list
        }
      },
    );
  }
}
