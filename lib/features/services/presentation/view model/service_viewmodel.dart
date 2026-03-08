import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/services/domain/usecases/package_usecase.dart';
import 'package:wheels_flutter/features/services/presentation/state/service_state.dart';

class ServicesViewModel extends StateNotifier<ServicesState> {
  final GetPackagesUsecase _getPackages;

  ServicesViewModel({required GetPackagesUsecase getPackages})
    : _getPackages = getPackages,
      super(const ServicesState());

  Future<void> loadPackages(String category) async {
    state = state.copyWith(status: ServicesStatus.loading, error: null);

    final result = await _getPackages(category);

    result.fold(
      (failure) => state = state.copyWith(
        status: ServicesStatus.error,
        error: failure.message,
      ),
      (packages) => state = state.copyWith(
        status: ServicesStatus.loaded,
        packages: packages,
        error: null,
      ),
    );
  }
}
