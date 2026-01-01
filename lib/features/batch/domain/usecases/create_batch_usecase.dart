import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import 'package:wheels_flutter/features/batch/domain/entities/batch_entity.dart';
import '../../../../core/error/failure.dart';
import '../repositories/batch_repository.dart';

class CreateBatchUsecaseParams extends Equatable {
  final String batchName;

  const CreateBatchUsecaseParams({required this.batchName});

  @override
  List<Object> get props => [batchName];
}

class CreateBatchUsecase
    implements UsecaseWithParams<void, CreateBatchUsecaseParams> {
  final IBatchRepository _batchRepository;

  CreateBatchUsecase(this._batchRepository);

  @override
  Future<Either<Failure, void>> call(CreateBatchUsecaseParams params) {
    // Create a BatchEntity using the provided params
    final batch = BatchEntity(batchName: params.batchName);
    return _batchRepository.createBatch(batch);
  }
}
