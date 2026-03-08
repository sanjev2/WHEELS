import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';

void main() {
  test('ProviderEntity equality works', () {
    const a = ProviderEntity(
      id: '1',
      name: 'Garage',
      locationText: 'Kathmandu',
      openFrom: '9',
      openTo: '6',
      lat: 1,
      lng: 2,
      categories: ['SUV'],
    );
    const b = ProviderEntity(
      id: '1',
      name: 'Garage',
      locationText: 'Kathmandu',
      openFrom: '9',
      openTo: '6',
      lat: 1,
      lng: 2,
      categories: ['SUV'],
    );

    expect(a, b);
  });
}
