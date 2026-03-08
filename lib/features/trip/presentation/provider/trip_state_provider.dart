// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:wheels_flutter/features/trip/data/trip_hive_model.dart';

// import '../../../auth/presentation/providers/auth_providers.dart';
// import '../../logic/trip_local_datasource.dart';

// class TripStats {
//   final double totalKm;
//   final double monthKm;
//   final int tripsCount;
//   final int unsyncedCount;

//   TripStats({
//     required this.totalKm,
//     required this.monthKm,
//     required this.tripsCount,
//     required this.unsyncedCount,
//   });
// }

// final tripHistoryProvider = FutureProvider<List<TripHiveModel>>((ref) async {
//   final userId = (ref.watch(currentUserIdProvider) ?? "").trim();
//   if (userId.isEmpty) return [];

//   final ds = ref.read(tripLocalDatasourceProvider);
//   return ds.getAllTripsForUser(userId);
// });

// final tripStatsProvider = FutureProvider<TripStats>((ref) async {
//   final userId = (ref.watch(currentUserIdProvider) ?? "").trim();
//   if (userId.isEmpty) {
//     return TripStats(totalKm: 0, monthKm: 0, tripsCount: 0, unsyncedCount: 0);
//   }

//   final ds = ref.read(tripLocalDatasourceProvider);
//   final all = await ds.getAllTripsForUser(userId);

//   final now = DateTime.now();
//   final startOfMonth = DateTime(now.year, now.month, 1);

//   double totalMeters = 0;
//   double monthMeters = 0;
//   int tripsCount = 0;
//   int unsyncedCount = 0;

//   for (final t in all) {
//     // ✅ count only completed trips
//     if (t.endTime == null) continue;
//     if (t.distanceMeters <= 0) continue;

//     tripsCount += 1;
//     totalMeters += t.distanceMeters;

//     if (!t.startTime.isBefore(startOfMonth)) {
//       monthMeters += t.distanceMeters;
//     }
//     if (!t.isSynced) unsyncedCount += 1;
//   }

//   return TripStats(
//     totalKm: totalMeters / 1000.0,
//     monthKm: monthMeters / 1000.0,
//     tripsCount: tripsCount,
//     unsyncedCount: unsyncedCount,
//   );
// });
