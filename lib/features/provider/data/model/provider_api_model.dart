import 'package:wheels_flutter/features/provider/domain/entities/provider_entities.dart';

class ProviderApiModel {
  final String id;
  final String name;
  final String? locationText;
  final String openFrom;
  final String openTo;
  final double lat;
  final double lng;
  final List<String> categories;

  ProviderApiModel({
    required this.id,
    required this.name,
    required this.locationText,
    required this.openFrom,
    required this.openTo,
    required this.lat,
    required this.lng,
    required this.categories,
  });

  factory ProviderApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderApiModel(
      id: (json["_id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      locationText: json["locationText"]?.toString(),
      openFrom: (json["openFrom"] ?? "").toString(),
      openTo: (json["openTo"] ?? "").toString(),
      lat: (json["lat"] is num) ? (json["lat"] as num).toDouble() : 0.0,
      lng: (json["lng"] is num) ? (json["lng"] as num).toDouble() : 0.0,
      categories: (json["categories"] is List)
          ? (json["categories"] as List).map((e) => e.toString()).toList()
          : <String>[],
    );
  }

  ProviderEntity toEntity() {
    return ProviderEntity(
      id: id,
      name: name,
      locationText: locationText,
      openFrom: openFrom,
      openTo: openTo,
      lat: lat,
      lng: lng,
      categories: categories,
    );
  }
}
