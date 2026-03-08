import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usercases/usecases.dart';
import '../repositories/car_repository.dart';

class DeleteCarParams extends Equatable {
  final String id;
  const DeleteCarParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteCarUsecase implements UsecaseWithParams<bool, DeleteCarParams> {
  final ICarRepository _repo;
  DeleteCarUsecase({required ICarRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, bool>> call(DeleteCarParams params) {
    return _repo.deleteCar(params.id);
  }
}
