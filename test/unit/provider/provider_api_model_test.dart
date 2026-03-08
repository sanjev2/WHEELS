import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/provider/data/model/provider_api_model.dart';

void main() {
  group('ProviderApiModel', () {
    test('fromJson maps values correctly', () {
      final model = ProviderApiModel.fromJson({
        '_id': 'p1',
        'name': 'Garage A',
        'locationText': 'Kathmandu',
        'openFrom': '09:00',
        'openTo': '18:00',
        'lat': 27.7,
        'lng': 85.3,
        'categories': ['SUV', 'SEDAN'],
      });

      expect(model.id, 'p1');
      expect(model.name, 'Garage A');
      expect(model.locationText, 'Kathmandu');
      expect(model.openFrom, '09:00');
      expect(model.openTo, '18:00');
      expect(model.lat, 27.7);
      expect(model.lng, 85.3);
      expect(model.categories, ['SUV', 'SEDAN']);
    });

    test('toEntity maps values correctly', () {
      final entity = ProviderApiModel(
        id: 'p1',
        name: 'Garage A',
        locationText: 'Kathmandu',
        openFrom: '09:00',
        openTo: '18:00',
        lat: 27.7,
        lng: 85.3,
        categories: const ['SUV'],
      ).toEntity();

      expect(entity.id, 'p1');
      expect(entity.name, 'Garage A');
      expect(entity.locationText, 'Kathmandu');
    });
  });
}
