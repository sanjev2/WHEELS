import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/features/batch/domain/entities/batch_entity.dart';

enum BatchStatus { initial, loading, loaded, error, created, updated, deleted }

class BatchState extends Equatable {
  final BatchStatus status;
  final List<BatchEntity> batches;
  final String? errorMessage;

  const BatchState({
    this.status = BatchStatus.initial,
    this.batches = const [],
    this.errorMessage,
  });

  BatchState copyWith({
    BatchStatus? status,
    List<BatchEntity>? batches,
    String? errorMessage,
  }) {
    return BatchState(
      status: status ?? this.status,
      batches: batches ?? this.batches,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, batches, errorMessage];
}
