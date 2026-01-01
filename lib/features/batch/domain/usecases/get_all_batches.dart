import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/core/usercases/usecases.dart';
import '../../../../core/error/failure.dart';
import '../entities/batch_entity.dart';
import '../repositories/batch_repository.dart';

class GetAllBatchUsecase implements UsecaseWithoutParams<List<BatchEntity>> {
  final IBatchRepository _batchRepository;

  GetAllBatchUsecase({required IBatchRepository batchRepository})
    : _batchRepository = batchRepository;

  @override
  Future<Either<Failure, List<BatchEntity>>> call() {
    return _batchRepository.getAllBatches();
  }
}
