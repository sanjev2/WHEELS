class TripRemoteModel {
  final String id;
  final String userId;
  final String carId;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceMeters;
  final bool isSynced;
  final DateTime updatedAt;

  const TripRemoteModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.isSynced,
    required this.updatedAt,
  });

  factory TripRemoteModel.fromJson(Map<String, dynamic> json) {
    return TripRemoteModel(
      id: (json["tripId"] ?? json["id"] ?? "").toString(),
      userId: (json["userId"] ?? "").toString(),
      carId: (json["carId"] ?? "").toString(),
      startTime: DateTime.parse(json["startTime"].toString()),
      endTime: json["endTime"] != null
          ? DateTime.parse(json["endTime"].toString())
          : null,
      distanceMeters: (json["distanceMeters"] as num?)?.toDouble() ?? 0.0,
      isSynced: true,
      updatedAt:
          DateTime.tryParse(
            (json["updatedAtFromDevice"] ?? json["updatedAt"] ?? "").toString(),
          ) ??
          DateTime.now(),
    );
  }
}
