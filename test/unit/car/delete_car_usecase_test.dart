import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/car/domain/repositories/car_repository.dart';
import 'package:wheels_flutter/features/car/domain/usercases/delete_car_usecase.dart';

class MockCarRepository extends Mock implements ICarRepository {}

void main() {
  late MockCarRepository repository;
  late DeleteCarUsecase usecase;

  setUp(() {
    repository = MockCarRepository();
    usecase = DeleteCarUsecase(repo: repository);
  });

  test('calls repo.deleteCar and returns true on success', () async {
    when(
      () => repository.deleteCar('c1'),
    ).thenAnswer((_) async => const Right(true));

    final result = await usecase(const DeleteCarParams(id: 'c1'));

    expect(result, const Right<Failure, bool>(true));
    verify(() => repository.deleteCar('c1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when repo.deleteCar fails', () async {
    final failure = ApiFailure(message: 'Delete failed');

    when(
      () => repository.deleteCar('c1'),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase(const DeleteCarParams(id: 'c1'));

    expect(result, Left<Failure, bool>(failure));
    verify(() => repository.deleteCar('c1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('DeleteCarParams props work correctly', () {
    const p1 = DeleteCarParams(id: 'c1');
    const p2 = DeleteCarParams(id: 'c1');

    expect(p1, equals(p2));
    expect(p1.props, ['c1']);
  });
}
