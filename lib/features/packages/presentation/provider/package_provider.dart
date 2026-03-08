import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/packages/data/repositories/package.repositories_impl.dart';
import 'package:wheels_flutter/features/packages/domain/usecases/get_package_usecase.dart';
import 'package:wheels_flutter/features/packages/presentation/state/package_state.dart';
import 'package:wheels_flutter/features/packages/presentation/view%20model/package_view_model.dart';

final getPackagesUsecaseProvider = Provider<GetPackagesUsecase>((ref) {
  final repo = ref.read(packageRepositoryProvider);
  return GetPackagesUsecase(repo: repo);
});

final packageViewModelProvider =
    StateNotifierProvider<PackageViewModel, PackageState>((ref) {
      final usecase = ref.read(getPackagesUsecaseProvider);
      return PackageViewModel(usecase: usecase);
    });
