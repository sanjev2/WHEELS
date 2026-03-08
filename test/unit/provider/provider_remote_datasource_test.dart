import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/api/api_endpoints.dart';
import 'package:wheels_flutter/features/provider/data/datasource/remote/provider_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late ProviderRemoteDatasource datasource;

  setUp(() {
    apiClient = MockApiClient();
    datasource = ProviderRemoteDatasource(apiClient: apiClient);
  });

  test('returns providers on success', () async {
    when(() => apiClient.get(
      ApiEndpoints.PublicProviders,
      queryParameters: {'category': 'SUV'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: ApiEndpoints.PublicProviders),
      data: {
        'success': true,
        'data': [
          {
            '_id': '1',
            'name': 'Garage A',
            'locationText': 'Kathmandu',
            'openFrom': '09:00',
            'openTo': '18:00',
            'lat': 27.7,
            'lng': 85.3,
            'categories': ['SUV']
          }
        ]
      },
    ));

    final result = await datasource.getProviders(category: 'SUV');

    expect(result, hasLength(1));
    expect(result.first.name, 'Garage A');
  });

  test('throws exception on bad response', () async {
    when(() => apiClient.get(
      ApiEndpoints.PublicProviders,
      queryParameters: {'category': 'SUV'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: ApiEndpoints.PublicProviders),
      data: {'success': false, 'message': 'Failed to load providers'},
    ));

    expect(
      () => datasource.getProviders(category: 'SUV'),
      throwsA(isA<Exception>()),
    );
  });
}
