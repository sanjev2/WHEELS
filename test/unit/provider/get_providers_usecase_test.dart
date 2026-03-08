import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';
import 'package:wheels_flutter/features/provider/domain/repositories/provider_repositories.dart';
import 'package:wheels_flutter/features/provider/domain/usecases/get_provider_usecase.dart';

class MockProviderRepository extends Mock implements IProviderRepository {}

void main() {
  late MockProviderRepository repo;
  late GetProvidersUsecase usecase;

  setUp(() {
    repo = MockProviderRepository();
    usecase = GetProvidersUsecase(repo: repo);
  });

  test('forwards call to repository', () async {
    when(() => repo.getProviders('SUV')).thenAnswer((_) async => const Right([
      ProviderEntity(
        id: '1',
        name: 'Garage A',
        locationText: 'Kathmandu',
        openFrom: '09:00',
        openTo: '18:00',
        lat: 1,
        lng: 2,
        categories: ['SUV'],
      )
    ]));

    final result = await usecase('SUV');

    expect(result.isRight(), isTrue);
    verify(() => repo.getProviders('SUV')).called(1);
  });
}
