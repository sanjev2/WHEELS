import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/car_entity.dart';

part 'car_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.carTypeId)
class CarHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String make;

  @HiveField(2)
  final String model;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final String licensePlate;

  @HiveField(5)
  final String fuelType;

  @HiveField(6)
  final DateTime boughtDate;

  @HiveField(7)
  final String category;

  CarHiveModel({
    String? id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.fuelType,
    required this.boughtDate,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  CarEntity toEntity() => CarEntity(
    id: id,
    make: make,
    model: model,
    year: year,
    licensePlate: licensePlate,
    fuelType: fuelType,
    boughtDate: boughtDate,
    category: category,
  );

  factory CarHiveModel.fromEntity(CarEntity e) => CarHiveModel(
    id: e.id,
    make: e.make,
    model: e.model,
    year: e.year,
    licensePlate: e.licensePlate,
    fuelType: e.fuelType,
    boughtDate: e.boughtDate,
    category: e.category,
  );
}
