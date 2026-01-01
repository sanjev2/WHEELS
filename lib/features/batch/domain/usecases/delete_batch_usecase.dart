import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import '../../../../core/error/failure.dart';
import '../repositories/batch_repository.dart';

class DeleteBatchUsecaseParams extends Equatable {
  final String batchId;

  const DeleteBatchUsecaseParams({required this.batchId});

  @override
  List<Object> get props => [batchId];
}

class DeleteBatchUsecase
    implements UsecaseWithParams<bool, DeleteBatchUsecaseParams> {
  final IBatchRepository _batchRepository;

  DeleteBatchUsecase(this._batchRepository);

  @override
  Future<Either<Failure, bool>> call(DeleteBatchUsecaseParams params) {
    return _batchRepository.deleteBatch(params.batchId);
  }
}
