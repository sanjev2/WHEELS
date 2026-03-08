import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usercases/usecases.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class UpdateCarParams extends Equatable {
  final String id;
  final CarEntity car;

  const UpdateCarParams({required this.id, required this.car});

  @override
  List<Object?> get props => [id, car];
}

class UpdateCarUsecase
    implements UsecaseWithParams<CarEntity, UpdateCarParams> {
  final ICarRepository _repo;
  UpdateCarUsecase({required ICarRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, CarEntity>> call(UpdateCarParams params) {
    return _repo.updateCar(params.id, params.car);
  }
}
