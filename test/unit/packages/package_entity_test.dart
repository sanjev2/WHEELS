import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

void main() {
  test('PackageEntity equality works', () {
    const a = PackageEntity(
      id: '1',
      title: 'Basic',
      description: 'desc',
      category: 'SUV',
      price: 1000,
      durationMins: 30,
      engineOilTypes: ['5W30'],
      services: ['Wash'],
      addons: ['Wax'],
      isActive: true,
    );

    const b = PackageEntity(
      id: '1',
      title: 'Basic',
      description: 'desc',
      category: 'SUV',
      price: 1000,
      durationMins: 30,
      engineOilTypes: ['5W30'],
      services: ['Wash'],
      addons: ['Wax'],
      isActive: true,
    );

    expect(a, b);
  });
}
