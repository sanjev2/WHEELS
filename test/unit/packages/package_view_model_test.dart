import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/packages/domain/usecases/get_package_usecase.dart';
import 'package:wheels_flutter/features/packages/presentation/state/package_state.dart';
import 'package:wheels_flutter/features/packages/presentation/view%20model/package_view_model.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

class MockGetPackagesUsecase extends Mock implements GetPackagesUsecase {}

void main() {
  late MockGetPackagesUsecase usecase;
  late PackageViewModel vm;

  setUp(() {
    usecase = MockGetPackagesUsecase();
    vm = PackageViewModel(usecase: usecase);
  });

  test('loadPackages emits loaded state on success', () async {
    when(() => usecase('SUV')).thenAnswer((_) async => const Right([
      PackageEntity(
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
      )
    ]));

    await vm.loadPackages('SUV');

    expect(vm.state.status, PackageStatus.loaded);
    expect(vm.state.packages, hasLength(1));
  });

  test('loadPackages emits error state on failure', () async {
    when(() => usecase('SUV')).thenAnswer((_) async => Left(const ApiFailure(message: 'failed')));

    await vm.loadPackages('SUV');

    expect(vm.state.status, PackageStatus.error);
    expect(vm.state.errorMessage, 'failed');
  });
}
