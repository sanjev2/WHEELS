import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

enum PackageStatus { initial, loading, loaded, error }

class PackageState extends Equatable {
  final PackageStatus status;
  final List<PackageEntity> packages;
  final String? errorMessage;

  const PackageState({
    this.status = PackageStatus.initial,
    this.packages = const [],
    this.errorMessage,
  });

  PackageState copyWith({
    PackageStatus? status,
    List<PackageEntity>? packages,
    String? errorMessage,
  }) {
    return PackageState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, packages, errorMessage];
}
