import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/services/data/datasource/repositories/service_repositories_impl.dart';
import 'package:wheels_flutter/features/services/domain/usecases/package_usecase.dart';
import 'package:wheels_flutter/features/services/presentation/state/service_state.dart';
import 'package:wheels_flutter/features/services/presentation/view%20model/service_viewmodel.dart';

final getPackagesUsecaseProvider = Provider<GetPackagesUsecase>((ref) {
  return GetPackagesUsecase(repo: ref.read(servicesRepositoryProvider));
});

final servicesViewModelProvider =
    StateNotifierProvider<ServicesViewModel, ServicesState>((ref) {
      return ServicesViewModel(
        getPackages: ref.read(getPackagesUsecaseProvider),
      );
    });
