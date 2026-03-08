import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/provider/domain/usecases/get_provider_usecase.dart';
import '../state/provider_state.dart';

class ProviderViewModel extends StateNotifier<ProviderState> {
  final GetProvidersUsecase _usecase;

  ProviderViewModel({required GetProvidersUsecase usecase})
    : _usecase = usecase,
      super(const ProviderState());

  Future<void> loadProviders(String category) async {
    state = state.copyWith(status: ProviderStatus.loading, errorMessage: null);

    final result = await _usecase(category);
    result.fold(
      (failure) => state = state.copyWith(
        status: ProviderStatus.error,
        errorMessage: failure.message,
      ),
      (list) => state = state.copyWith(
        status: ProviderStatus.loaded,
        providers: list,
        errorMessage: null,
      ),
    );
  }
}
