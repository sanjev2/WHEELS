import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/features/car/domain/usercases/add_car_usecase.dart';
import 'package:wheels_flutter/features/car/domain/usercases/car_usecase.dart';
import 'package:wheels_flutter/features/car/domain/usercases/delete_car_usecase.dart';
import 'package:wheels_flutter/features/car/domain/usercases/update_car_usecase.dart';

import '../../domain/entities/car_entity.dart';
import '../state/car_state.dart';

class CarViewModel extends StateNotifier<CarState> {
  final GetMyCarsUsecase _getMyCarsUsecase;
  final AddCarUsecase _addCarUsecase;
  final DeleteCarUsecase _deleteCarUsecase;
  final UpdateCarUsecase _updateCarUsecase;

  CarViewModel({
    required GetMyCarsUsecase getMyCarsUsecase,
    required AddCarUsecase addCarUsecase,
    required DeleteCarUsecase deleteCarUsecase,
    required UpdateCarUsecase updateCarUsecase,
  }) : _getMyCarsUsecase = getMyCarsUsecase,
       _addCarUsecase = addCarUsecase,
       _deleteCarUsecase = deleteCarUsecase,
       _updateCarUsecase = updateCarUsecase,
       super(const CarState());

  Future<void> loadMyCars() async {
    state = state.copyWith(status: CarStatus.loading, errorMessage: null);

    final result = await _getMyCarsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: CarStatus.error,
        errorMessage: failure.message,
      ),
      (cars) => state = state.copyWith(
        status: CarStatus.loaded,
        cars: cars,
        errorMessage: null,
      ),
    );
  }

  Future<bool> addCar(CarEntity car) async {
    state = state.copyWith(status: CarStatus.loading, errorMessage: null);

    final result = await _addCarUsecase(AddCarParams(car: car));
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CarStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (created) {
        final updatedList = [created, ...state.cars];
        state = state.copyWith(status: CarStatus.success, cars: updatedList);
        return true;
      },
    );
  }

  Future<bool> deleteCar(String id) async {
    state = state.copyWith(status: CarStatus.loading, errorMessage: null);

    final result = await _deleteCarUsecase(DeleteCarParams(id: id));
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CarStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        final updated = state.cars.where((c) => c.id != id).toList();
        state = state.copyWith(status: CarStatus.success, cars: updated);
        return true;
      },
    );
  }

  Future<bool> updateCar(String id, CarEntity car) async {
    state = state.copyWith(status: CarStatus.loading, errorMessage: null);

    final result = await _updateCarUsecase(UpdateCarParams(id: id, car: car));
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CarStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedCar) {
        final updatedList = state.cars.map((c) {
          return c.id == id ? updatedCar : c;
        }).toList();

        state = state.copyWith(status: CarStatus.success, cars: updatedList);
        return true;
      },
    );
  }
}
