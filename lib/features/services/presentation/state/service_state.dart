import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

enum ServicesStatus { initial, loading, loaded, error }

class ServicesState extends Equatable {
  final ServicesStatus status;
  final List<PackageEntity> packages;
  final String? error;

  const ServicesState({
    this.status = ServicesStatus.initial,
    this.packages = const [],
    this.error,
  });

  ServicesState copyWith({
    ServicesStatus? status,
    List<PackageEntity>? packages,
    String? error,
  }) {
    return ServicesState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, packages, error];
}
