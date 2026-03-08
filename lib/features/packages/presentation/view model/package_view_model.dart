import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/packages/domain/usecases/get_package_usecase.dart';
import '../state/package_state.dart';

class PackageViewModel extends StateNotifier<PackageState> {
  final GetPackagesUsecase _usecase;

  PackageViewModel({required GetPackagesUsecase usecase})
    : _usecase = usecase,
      super(const PackageState());

  Future<void> loadPackages(String category) async {
    state = state.copyWith(status: PackageStatus.loading, errorMessage: null);

    final result = await _usecase(category);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PackageStatus.error,
          errorMessage: failure.message,
        );
      },
      (packages) {
        state = state.copyWith(
          status: PackageStatus.loaded,
          packages: packages,
          errorMessage: null,
        );
      },
    );
  }
}
