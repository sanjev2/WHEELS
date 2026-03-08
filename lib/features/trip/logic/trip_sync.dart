import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:wheels_flutter/features/trip/logic/trip_local_datasource.dart';
import 'package:wheels_flutter/features/trip/logic/trip_remote_datasource.dart';
import 'package:wheels_flutter/features/trip/logic/trip_provider.dart';

final tripSyncControllerProvider =
    StateNotifierProvider<TripSyncController, AsyncValue<void>>((ref) {
      return TripSyncController(ref);
    });

class TripSyncController extends StateNotifier<AsyncValue<void>> {
  TripSyncController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> syncNow() async {
    state = const AsyncLoading();

    try {
      final userId = (ref.read(currentUserIdProvider) ?? "").trim();
      if (userId.isEmpty) {
        throw Exception("User not found. Please login again.");
      }

      final local = ref.read(tripLocalDatasourceProvider);
      final remote = ref.read(tripRemoteDatasourceProvider);

      final trips = await local.getUnsyncedTrips(userId);

      if (trips.isEmpty) {
        state = const AsyncData(null);
        return;
      }

      await remote.syncTrips(trips: trips);

      for (final t in trips) {
        await local.markSynced(t.id);
      }

      state = const AsyncData(null);

      ref.invalidate(tripStatsProvider);
      ref.invalidate(tripHistoryProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
