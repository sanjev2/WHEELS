import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:wheels_flutter/core/constants/hive_constants.dart';
import 'package:wheels_flutter/features/trip/data/trip_hive_model.dart';

final tripLocalDatasourceProvider = Provider<TripLocalDatasource>((ref) {
  return TripLocalDatasource();
});

class TripLocalDatasource {
  Box<TripHiveModel> get _box =>
      Hive.box<TripHiveModel>(HiveTableConstant.tripTable);

  Future<void> upsert(TripHiveModel trip) async {
    await _box.put(trip.id, trip);
  }

  Future<TripHiveModel?> getById(String id) async {
    return _box.get(id);
  }

  Future<TripHiveModel?> getActiveTrip() async {
    try {
      return _box.values.firstWhere((t) => t.endTime == null);
    } catch (_) {
      return null;
    }
  }

  Future<List<TripHiveModel>> getAllTripsForUser(String userId) async {
    final list = _box.values.where((t) => t.userId == userId).toList();
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    return list;
  }

  Future<List<TripHiveModel>> getUnsyncedTrips(String userId) async {
    final list = _box.values
        .where(
          (t) => t.userId == userId && t.isSynced == false && t.endTime != null,
        )
        .toList();

    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> markSynced(String tripId) async {
    final t = _box.get(tripId);
    if (t == null) return;

    await _box.put(
      tripId,
      t.copyWith(isSynced: true, updatedAt: DateTime.now()),
    );
  }
}
