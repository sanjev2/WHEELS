import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usercases/usecases.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class GetMyCarsUsecase implements UsecaseWithoutParams<List<CarEntity>> {
  final ICarRepository _repo;
  GetMyCarsUsecase({required ICarRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, List<CarEntity>>> call() => _repo.getMyCars();
}
