import 'package:equatable/equatable.dart';

class CarEntity extends Equatable {
  final String? id; // backend _id
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String fuelType;
  final DateTime boughtDate;
  final String category;

  const CarEntity({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.fuelType,
    required this.boughtDate,
    required this.category,
  });

  @override
  List<Object?> get props => [
    id,
    make,
    model,
    year,
    licensePlate,
    fuelType,
    boughtDate,
    category,
  ];
}
