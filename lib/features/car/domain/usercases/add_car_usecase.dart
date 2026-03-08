import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usercases/usecases.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

class AddCarParams extends Equatable {
  final CarEntity car;
  const AddCarParams({required this.car});

  @override
  List<Object?> get props => [car];
}

class AddCarUsecase implements UsecaseWithParams<CarEntity, AddCarParams> {
  final ICarRepository _repo;
  AddCarUsecase({required ICarRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, CarEntity>> call(AddCarParams params) {
    return _repo.addCar(params.car);
  }
}
