import 'package:equatable/equatable.dart';

class PackageEntity extends Equatable {
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

  const PackageEntity({
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

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    price,
    durationMins,
    engineOilTypes,
    services,
    addons,
    isActive,
  ];
}
