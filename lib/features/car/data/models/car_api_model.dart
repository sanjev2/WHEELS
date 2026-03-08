import '../../domain/entities/car_entity.dart';

class CarApiModel {
  final String? id;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String fuelType;
  final DateTime boughtDate;
  final String category;

  CarApiModel({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.fuelType,
    required this.boughtDate,
    required this.category,
  });

  factory CarApiModel.fromJson(Map<String, dynamic> json) {
    final boughtRaw = json["boughtDate"];
    final bought = DateTime.tryParse(boughtRaw?.toString() ?? "");

    return CarApiModel(
      id: (json["_id"] ?? json["id"])?.toString(),
      make: (json["make"] ?? "").toString(),
      model: (json["model"] ?? "").toString(),
      year: int.tryParse(json["year"].toString()) ?? 0,
      licensePlate: (json["licensePlate"] ?? "").toString(),
      fuelType: (json["fuelType"] ?? "Petrol").toString(),
      boughtDate: bought ?? DateTime.now(),
      category: (json["category"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "make": make.trim(),
    "model": model.trim(),
    "year": year,
    "licensePlate": licensePlate.trim().toUpperCase(),
    "fuelType": fuelType,
    "boughtDate": boughtDate.toIso8601String(),
    "category": category,
  };

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

  factory CarApiModel.fromEntity(CarEntity e) => CarApiModel(
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
