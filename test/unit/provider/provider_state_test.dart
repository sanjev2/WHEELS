import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';
import 'package:wheels_flutter/features/provider/presentation/state/provider_state.dart';

void main() {
  test('copyWith updates provider state', () {
    const state = ProviderState();
    const provider = ProviderEntity(
      id: '1',
      name: 'Garage A',
      locationText: 'Kathmandu',
      openFrom: '09:00',
      openTo: '18:00',
      lat: 1,
      lng: 2,
      categories: ['SUV'],
    );

    final updated = state.copyWith(
      status: ProviderStatus.loaded,
      providers: const [provider],
    );

    expect(updated.status, ProviderStatus.loaded);
    expect(updated.providers, const [provider]);
  });
}
