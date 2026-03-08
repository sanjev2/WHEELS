import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/car/domain/entities/car_entity.dart';
import 'package:wheels_flutter/features/car/domain/repositories/car_repository.dart';
import 'package:wheels_flutter/features/car/domain/usercases/car_usecase.dart';

class MockCarRepository extends Mock implements ICarRepository {}

CarEntity makeCar({
  String? id = 'c1',
  String make = 'Toyota',
  String model = 'Yaris',
  int year = 2022,
  String licensePlate = 'BA-1-PA-1234',
  String fuelType = 'Petrol',
  DateTime? boughtDate,
  String category = 'SUV',
}) {
  return CarEntity(
    id: id,
    make: make,
    model: model,
    year: year,
    licensePlate: licensePlate,
    fuelType: fuelType,
    boughtDate: boughtDate ?? DateTime(2024, 1, 1),
    category: category,
  );
}

void main() {
  late MockCarRepository repository;
  late GetMyCarsUsecase usecase;

  setUp(() {
    repository = MockCarRepository();
    usecase = GetMyCarsUsecase(repo: repository);
  });

  test('calls repo.getMyCars and returns list on success', () async {
    final cars = [makeCar(), makeCar(id: 'c2', model: 'Corolla')];

    when(() => repository.getMyCars()).thenAnswer((_) async => Right(cars));

    final result = await usecase();

    expect(result, Right<Failure, List<CarEntity>>(cars));
    verify(() => repository.getMyCars()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when repo.getMyCars fails', () async {
    final failure = ApiFailure(message: 'Load failed');

    when(() => repository.getMyCars()).thenAnswer((_) async => Left(failure));

    final result = await usecase();

    expect(result, Left<Failure, List<CarEntity>>(failure));
    verify(() => repository.getMyCars()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
