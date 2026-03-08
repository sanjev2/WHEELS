import 'package:equatable/equatable.dart';

class ProviderEntity extends Equatable {
  final String id;
  final String name;
  final String? locationText;
  final String openFrom;
  final String openTo;
  final double lat;
  final double lng;
  final List<String> categories;

  const ProviderEntity({
    required this.id,
    required this.name,
    required this.locationText,
    required this.openFrom,
    required this.openTo,
    required this.lat,
    required this.lng,
    required this.categories,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    locationText,
    openFrom,
    openTo,
    lat,
    lng,
    categories,
  ];
}
