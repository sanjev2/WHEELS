import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/api/api_endpoints.dart';
import 'package:wheels_flutter/features/packages/data/remote/package_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late PackageRemoteDatasource datasource;

  setUp(() {
    apiClient = MockApiClient();
    datasource = PackageRemoteDatasource(apiClient: apiClient);
  });

  test('returns package models on success', () async {
    when(() => apiClient.get(
      ApiEndpoints.PublicPackages,
      queryParameters: {'category': 'SUV'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: ApiEndpoints.PublicPackages),
      data: {
        'success': true,
        'data': [
          {
            '_id': 'p1',
            'title': 'Basic',
            'category': 'SUV',
            'price': 1200,
            'durationMins': 30,
            'engineOilTypes': ['5W30'],
            'services': ['Wash'],
            'addons': ['Wax'],
            'isActive': true,
          }
        ]
      },
    ));

    final result = await datasource.getPackages(category: 'SUV');

    expect(result, hasLength(1));
    expect(result.first.id, 'p1');
    verify(() => apiClient.get(
      ApiEndpoints.PublicPackages,
      queryParameters: {'category': 'SUV'},
    )).called(1);
  });

  test('throws exception when success is false', () async {
    when(() => apiClient.get(
      ApiEndpoints.PublicPackages,
      queryParameters: {'category': 'SUV'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: ApiEndpoints.PublicPackages),
      data: {'success': false, 'message': 'Failed to load packages'},
    ));

    expect(
      () => datasource.getPackages(category: 'SUV'),
      throwsA(isA<Exception>()),
    );
  });
}
