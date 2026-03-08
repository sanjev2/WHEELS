import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/services/data/model/package_api_model.dart';

void main() {
  group('PackageApiModel', () {
    test('fromJson maps values correctly', () {
      final model = PackageApiModel.fromJson({
        '_id': 'p1',
        'title': 'Premium Wash',
        'description': 'Full wash',
        'category': 'SUV',
        'price': 2500,
        'durationMins': 45,
        'engineOilTypes': ['5W30', '10W40'],
        'services': ['Wash', 'Vacuum'],
        'addons': ['Wax'],
        'isActive': true,
      });

      expect(model.id, 'p1');
      expect(model.title, 'Premium Wash');
      expect(model.description, 'Full wash');
      expect(model.category, 'SUV');
      expect(model.price, 2500);
      expect(model.durationMins, 45);
      expect(model.engineOilTypes, ['5W30', '10W40']);
      expect(model.services, ['Wash', 'Vacuum']);
      expect(model.addons, ['Wax']);
      expect(model.isActive, isTrue);
    });

    test('fromJson falls back safely on invalid values', () {
      final model = PackageApiModel.fromJson({
        '_id': null,
        'title': null,
        'category': null,
        'price': 'bad',
        'durationMins': 'bad',
        'engineOilTypes': 'bad',
        'services': 'bad',
        'addons': 'bad',
        'isActive': false,
      });

      expect(model.id, '');
      expect(model.title, '');
      expect(model.category, '');
      expect(model.price, 0);
      expect(model.durationMins, isNull);
      expect(model.engineOilTypes, isEmpty);
      expect(model.services, isEmpty);
      expect(model.addons, isEmpty);
      expect(model.isActive, isFalse);
    });

    test('toEntity maps values correctly', () {
      final model = PackageApiModel(
        id: 'p1',
        title: 'Premium Wash',
        description: 'Full wash',
        category: 'SUV',
        price: 2500,
        durationMins: 45,
        engineOilTypes: const ['5W30'],
        services: const ['Wash'],
        addons: const ['Wax'],
        isActive: true,
      );

      final entity = model.toEntity();

      expect(entity.id, 'p1');
      expect(entity.title, 'Premium Wash');
      expect(entity.description, 'Full wash');
      expect(entity.category, 'SUV');
      expect(entity.price, 2500);
      expect(entity.durationMins, 45);
      expect(entity.engineOilTypes, ['5W30']);
      expect(entity.services, ['Wash']);
      expect(entity.addons, ['Wax']);
      expect(entity.isActive, isTrue);
    });
  });
}
