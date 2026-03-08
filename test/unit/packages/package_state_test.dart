import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/packages/presentation/state/package_state.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

void main() {
  test('copyWith updates state', () {
    const initial = PackageState();
    const pkg = PackageEntity(
      id: '1',
      title: 'Basic',
      description: null,
      category: 'SUV',
      price: 1000,
      durationMins: 30,
      engineOilTypes: [],
      services: [],
      addons: [],
      isActive: true,
    );

    final updated = initial.copyWith(
      status: PackageStatus.loaded,
      packages: const [pkg],
      errorMessage: null,
    );

    expect(updated.status, PackageStatus.loaded);
    expect(updated.packages, const [pkg]);
  });
}
