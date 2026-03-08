import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/features/services/data/model/package_api_model.dart';
import 'package:wheels_flutter/features/packages/data/repositories/package.repositories_impl.dart';
import 'package:wheels_flutter/features/packages/data/remote/package_remote_datasource.dart';

class MockPackageRemoteDatasource extends Mock implements PackageRemoteDatasource {}

void main() {
  late MockPackageRemoteDatasource remote;
  late PackageRepositoryImpl repo;

  setUp(() {
    remote = MockPackageRemoteDatasource();
    repo = PackageRepositoryImpl(remote: remote);
  });

  test('returns only active package entities', () async {
    when(() => remote.getPackages(category: 'SUV')).thenAnswer((_) async => [
      PackageApiModel(
        id: '1',
        title: 'Active',
        description: null,
        category: 'SUV',
        price: 1000,
        durationMins: 30,
        engineOilTypes: const [],
        services: const [],
        addons: const [],
        isActive: true,
      ),
      PackageApiModel(
        id: '2',
        title: 'Inactive',
        description: null,
        category: 'SUV',
        price: 900,
        durationMins: 25,
        engineOilTypes: const [],
        services: const [],
        addons: const [],
        isActive: false,
      ),
    ]);

    final result = await repo.getPackages('SUV');

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected right'), (list) {
      expect(list, hasLength(1));
      expect(list.first.id, '1');
    });
  });

  test('returns ApiFailure on DioException', () async {
    when(() => remote.getPackages(category: 'SUV')).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/packages'), message: 'Network down'),
    );

    final result = await repo.getPackages('SUV');

    expect(result.isLeft(), isTrue);
  });

  test('returns ApiFailure on generic exception', () async {
    when(() => remote.getPackages(category: 'SUV')).thenThrow(Exception('boom'));

    final result = await repo.getPackages('SUV');

    expect(result.isLeft(), isTrue);
  });
}
