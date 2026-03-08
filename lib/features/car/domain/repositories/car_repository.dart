import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/car_entity.dart';

abstract interface class ICarRepository {
  Future<Either<Failure, List<CarEntity>>> getMyCars();
  Future<Either<Failure, CarEntity>> addCar(CarEntity car);
  Future<Either<Failure, bool>> deleteCar(String id);

  Future<Either<Failure, CarEntity>> updateCar(String id, CarEntity car);
}
