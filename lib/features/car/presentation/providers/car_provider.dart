import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/features/car/data/repositories/car_repositories_impl.dart';
import 'package:wheels_flutter/features/car/domain/usercases/add_car_usecase.dart';
import 'package:wheels_flutter/features/car/domain/usercases/car_usecase.dart';
import 'package:wheels_flutter/features/car/domain/usercases/delete_car_usecase.dart';
import 'package:wheels_flutter/features/car/domain/usercases/update_car_usecase.dart';

import 'package:wheels_flutter/features/car/presentation/view model/car_view_model.dart';
import '../state/car_state.dart';

final getMyCarsUsecaseProvider = Provider<GetMyCarsUsecase>((ref) {
  return GetMyCarsUsecase(repo: ref.read(carRepositoryProvider));
});

final addCarUsecaseProvider = Provider<AddCarUsecase>((ref) {
  return AddCarUsecase(repo: ref.read(carRepositoryProvider));
});

final deleteCarUsecaseProvider = Provider<DeleteCarUsecase>((ref) {
  return DeleteCarUsecase(repo: ref.read(carRepositoryProvider));
});

final updateCarUsecaseProvider = Provider<UpdateCarUsecase>((ref) {
  return UpdateCarUsecase(repo: ref.read(carRepositoryProvider));
});

final carViewModelProvider = StateNotifierProvider<CarViewModel, CarState>((
  ref,
) {
  return CarViewModel(
    getMyCarsUsecase: ref.read(getMyCarsUsecaseProvider),
    addCarUsecase: ref.read(addCarUsecaseProvider),
    deleteCarUsecase: ref.read(deleteCarUsecaseProvider),
    updateCarUsecase: ref.read(updateCarUsecaseProvider),
  );
});
