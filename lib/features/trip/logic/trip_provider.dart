import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:wheels_flutter/features/trip/data/trip_hive_model.dart';
import 'package:wheels_flutter/features/trip/logic/trip_local_datasource.dart';
import 'package:wheels_flutter/features/trip/logic/trip_remote_datasource.dart';

class TripStats {
  final double totalKm;
  final double monthKm;
  final int tripsCount;
  final int unsyncedCount;

  const TripStats({
    required this.totalKm,
    required this.monthKm,
    required this.tripsCount,
    required this.unsyncedCount,
  });
}

class TripHistoryItem {
  final String id;
  final String userId;
  final String carId;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceMeters;
  final bool isSynced;
  final DateTime updatedAt;

  const TripHistoryItem({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    required this.isSynced,
    required this.updatedAt,
  });

  factory TripHistoryItem.fromLocal(TripHiveModel t) {
    return TripHistoryItem(
      id: t.id,
      userId: t.userId,
      carId: t.carId,
      startTime: t.startTime,
      endTime: t.endTime,
      distanceMeters: t.distanceMeters,
      isSynced: t.isSynced,
      updatedAt: t.updatedAt,
    );
  }

  factory TripHistoryItem.fromRemote(TripRemoteModel t) {
    return TripHistoryItem(
      id: t.id,
      userId: t.userId,
      carId: t.carId,
      startTime: t.startTime,
      endTime: t.endTime,
      distanceMeters: t.distanceMeters,
      isSynced: t.isSynced,
      updatedAt: t.updatedAt,
    );
  }
}

final tripHistoryProvider = FutureProvider<List<TripHistoryItem>>((ref) async {
  final userId = (ref.watch(currentUserIdProvider) ?? "").trim();

  debugPrint("tripHistoryProvider userId => $userId");

  if (userId.isEmpty) return [];

  final remote = ref.read(tripRemoteDatasourceProvider);
  final local = ref.read(tripLocalDatasourceProvider);

  final remoteTrips = await remote.getTripsByUser(userId);
  final localTrips = await local.getAllTripsForUser(userId);

  debugPrint("tripHistoryProvider remote trips => ${remoteTrips.length}");
  debugPrint("tripHistoryProvider local trips => ${localTrips.length}");

  final Map<String, TripHistoryItem> merged = {};

  for (final t in remoteTrips) {
    merged[t.id] = TripHistoryItem.fromRemote(t);
  }

  for (final t in localTrips) {
    merged[t.id] = TripHistoryItem.fromLocal(t);
  }

  final list = merged.values.toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));

  return list;
});

final tripStatsProvider = FutureProvider<TripStats>((ref) async {
  final userId = (ref.watch(currentUserIdProvider) ?? "").trim();

  debugPrint("tripStatsProvider userId => $userId");

  if (userId.isEmpty) {
    return const TripStats(
      totalKm: 0,
      monthKm: 0,
      tripsCount: 0,
      unsyncedCount: 0,
    );
  }

  final history = await ref.read(tripHistoryProvider.future);
  final local = ref.read(tripLocalDatasourceProvider);
  final unsynced = await local.getUnsyncedTrips(userId);

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  double totalMeters = 0;
  double monthMeters = 0;
  int tripsCount = 0;

  for (final t in history) {
    if (t.endTime == null) continue;

    tripsCount += 1;

    if (t.distanceMeters > 0) {
      totalMeters += t.distanceMeters;

      if (!t.startTime.isBefore(startOfMonth)) {
        monthMeters += t.distanceMeters;
      }
    }
  }

  debugPrint("tripStatsProvider merged trips => ${history.length}");
  debugPrint("tripStatsProvider local unsynced => ${unsynced.length}");

  return TripStats(
    totalKm: totalMeters / 1000.0,
    monthKm: monthMeters / 1000.0,
    tripsCount: tripsCount,
    unsyncedCount: unsynced.length,
  );
});
