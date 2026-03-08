import 'package:hive/hive.dart';

part 'trip_hive_model.g.dart';

@HiveType(typeId: 20)
class TripHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String carId;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime? endTime;

  @HiveField(5)
  final double distanceMeters;

  @HiveField(6)
  final bool isSynced;

  @HiveField(7)
  final DateTime updatedAt;

  TripHiveModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.isSynced,
    required this.updatedAt,
  });

  TripHiveModel copyWith({
    DateTime? endTime,
    double? distanceMeters,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return TripHiveModel(
      id: id,
      userId: userId,
      carId: carId,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
