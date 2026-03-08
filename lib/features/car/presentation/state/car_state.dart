import 'package:equatable/equatable.dart';
import '../../domain/entities/car_entity.dart';

enum CarStatus { initial, loading, loaded, error, success }

class CarState extends Equatable {
  final CarStatus status;
  final List<CarEntity> cars;
  final String? errorMessage;

  const CarState({
    this.status = CarStatus.initial,
    this.cars = const [],
    this.errorMessage,
  });

  CarState copyWith({
    CarStatus? status,
    List<CarEntity>? cars,
    String? errorMessage,
  }) {
    return CarState(
      status: status ?? this.status,
      cars: cars ?? this.cars,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cars, errorMessage];
}
