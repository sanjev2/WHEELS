import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/features/provider/data/datasource/remote/provider_remote_datasource.dart';
import 'package:wheels_flutter/features/provider/data/model/provider_api_model.dart';
import 'package:wheels_flutter/features/provider/data/repositories/provider_repositories_impl.dart';

class MockProviderRemoteDatasource extends Mock implements ProviderRemoteDatasource {}

void main() {
  late MockProviderRemoteDatasource remote;
  late ProviderRepositoryImpl repo;

  setUp(() {
    remote = MockProviderRemoteDatasource();
    repo = ProviderRepositoryImpl(remote: remote);
  });

  test('returns provider entities on success', () async {
    when(() => remote.getProviders(category: 'SUV')).thenAnswer((_) async => [
      ProviderApiModel(
        id: '1',
        name: 'Garage A',
        locationText: 'Kathmandu',
        openFrom: '09:00',
        openTo: '18:00',
        lat: 1,
        lng: 2,
        categories: const ['SUV'],
      )
    ]);

    final result = await repo.getProviders('SUV');

    expect(result.isRight(), isTrue);
  });

  test('returns ApiFailure on DioException', () async {
    when(() => remote.getProviders(category: 'SUV')).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/providers'), message: 'Network'),
    );

    final result = await repo.getProviders('SUV');

    expect(result.isLeft(), isTrue);
  });
}
