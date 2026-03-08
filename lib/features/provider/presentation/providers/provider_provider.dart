import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/provider/data/repositories/provider_repositories_impl.dart';
import 'package:wheels_flutter/features/provider/domain/usecases/get_provider_usecase.dart';
import 'package:wheels_flutter/features/provider/presentation/view%20model/provider_viewmodel.dart';
import '../state/provider_state.dart';

final getProvidersUsecaseProvider = Provider<GetProvidersUsecase>((ref) {
  return GetProvidersUsecase(repo: ref.read(providerRepositoryProvider));
});

final providerViewModelProvider =
    StateNotifierProvider<ProviderViewModel, ProviderState>((ref) {
      return ProviderViewModel(usecase: ref.read(getProvidersUsecaseProvider));
    });
