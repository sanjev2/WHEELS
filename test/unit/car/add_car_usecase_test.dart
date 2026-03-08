import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/car/domain/entities/car_entity.dart';
import 'package:wheels_flutter/features/car/domain/repositories/car_repository.dart';
import 'package:wheels_flutter/features/car/domain/usercases/add_car_usecase.dart';

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
  late AddCarUsecase usecase;

  setUp(() {
    repository = MockCarRepository();
    usecase = AddCarUsecase(repo: repository);
  });

  test('calls repo.addCar and returns CarEntity on success', () async {
    final car = makeCar();

    when(() => repository.addCar(car)).thenAnswer((_) async => Right(car));

    final result = await usecase(AddCarParams(car: car));

    expect(result, Right<Failure, CarEntity>(car));
    verify(() => repository.addCar(car)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when repo.addCar fails', () async {
    final car = makeCar();
    final failure = ApiFailure(message: 'Add failed');

    when(() => repository.addCar(car)).thenAnswer((_) async => Left(failure));

    final result = await usecase(AddCarParams(car: car));

    expect(result, Left<Failure, CarEntity>(failure));
    verify(() => repository.addCar(car)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('AddCarParams props work correctly', () {
    final car = makeCar();
    final p1 = AddCarParams(car: car);
    final p2 = AddCarParams(car: car);

    expect(p1, equals(p2));
    expect(p1.props, [car]);
  });
}
