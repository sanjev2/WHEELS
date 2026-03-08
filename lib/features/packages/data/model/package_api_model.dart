import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

class PackageApiModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final int price;
  final int? durationMins;
  final List<String> engineOilTypes;
  final List<String> services;
  final List<String> addons;
  final bool isActive;

  PackageApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.durationMins,
    required this.engineOilTypes,
    required this.services,
    required this.addons,
    required this.isActive,
  });

  factory PackageApiModel.fromJson(Map<String, dynamic> json) {
    return PackageApiModel(
      id: (json["_id"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
      description: json["description"]?.toString(),
      category: (json["category"] ?? "").toString(),
      price: (json["price"] is num) ? (json["price"] as num).toInt() : 0,
      durationMins: (json["durationMins"] is num)
          ? (json["durationMins"] as num).toInt()
          : null,
      engineOilTypes: (json["engineOilTypes"] is List)
          ? (json["engineOilTypes"] as List).map((e) => e.toString()).toList()
          : <String>[],
      services: (json["services"] is List)
          ? (json["services"] as List).map((e) => e.toString()).toList()
          : <String>[],
      addons: (json["addons"] is List)
          ? (json["addons"] as List).map((e) => e.toString()).toList()
          : <String>[],
      isActive: json["isActive"] == true,
    );
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      durationMins: durationMins,
      engineOilTypes: engineOilTypes,
      services: services,
      addons: addons,
      isActive: isActive,
    );
  }
}
