import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import '../../../../core/error/failure.dart';
import '../entities/batch_entity.dart';
import '../repositories/batch_repository.dart';

class GetBatchByIdUsecaseParams extends Equatable {
  final String batchId;

  const GetBatchByIdUsecaseParams({required this.batchId});

  @override
  List<Object> get props => [batchId];
}

class GetBatchByIdUsecase
    implements UsecaseWithParams<BatchEntity, GetBatchByIdUsecaseParams> {
  final IBatchRepository _batchRepository;

  GetBatchByIdUsecase(this._batchRepository);

  @override
  Future<Either<Failure, BatchEntity>> call(GetBatchByIdUsecaseParams params) {
    return _batchRepository.getBatchById(params.batchId);
  }
}
