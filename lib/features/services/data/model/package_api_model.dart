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
    List<String> _list(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return PackageApiModel(
      id: (json["_id"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
      description: json["description"]?.toString(),
      category: (json["category"] ?? "").toString(),
      price: (json["price"] ?? 0) is int
          ? (json["price"] as int)
          : int.tryParse(json["price"].toString()) ?? 0,
      durationMins: json["durationMins"] == null
          ? null
          : (json["durationMins"] is int
                ? json["durationMins"] as int
                : int.tryParse(json["durationMins"].toString())),
      engineOilTypes: _list(json["engineOilTypes"]),
      services: _list(json["services"]),
      addons: _list(json["addons"]),
      isActive: (json["isActive"] ?? false) == true,
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
