import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';

enum ProviderStatus { initial, loading, loaded, error }

class ProviderState extends Equatable {
  final ProviderStatus status;
  final List<ProviderEntity> providers;
  final String? errorMessage;

  const ProviderState({
    this.status = ProviderStatus.initial,
    this.providers = const [],
    this.errorMessage,
  });

  ProviderState copyWith({
    ProviderStatus? status,
    List<ProviderEntity>? providers,
    String? errorMessage,
  }) {
    return ProviderState(
      status: status ?? this.status,
      providers: providers ?? this.providers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, providers, errorMessage];
}
