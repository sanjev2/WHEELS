import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/features/packages/domain/repositories/package_repository.dart';
import 'package:wheels_flutter/features/packages/domain/usecases/get_package_usecase.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

class MockPackageRepository extends Mock implements IPackageRepository {}

void main() {
  late MockPackageRepository repo;
  late GetPackagesUsecase usecase;

  setUp(() {
    repo = MockPackageRepository();
    usecase = GetPackagesUsecase(repo: repo);
  });

  test('forwards call to repository', () async {
    when(() => repo.getPackages('SUV')).thenAnswer((_) async => const Right([
      PackageEntity(
        id: '1',
        title: 'Basic',
        description: null,
        category: 'SUV',
        price: 1000,
        durationMins: 30,
        engineOilTypes: [],
        services: [],
        addons: [],
        isActive: true,
      )
    ]));

    final result = await usecase('SUV');

    expect(result.isRight(), isTrue);
    verify(() => repo.getPackages('SUV')).called(1);
  });
}
