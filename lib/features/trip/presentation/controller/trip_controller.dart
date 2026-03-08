import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import 'package:wheels_flutter/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:wheels_flutter/features/trip/data/trip_hive_model.dart';
import 'package:wheels_flutter/features/trip/logic/trip_local_datasource.dart';
import 'package:wheels_flutter/features/trip/foreground/trip_helper.dart';

enum TripStatus { idle, tracking, stopping, error }

class TripState {
  final TripStatus status;
  final String? activeTripId;
  final double distanceMeters;
  final String? errorMessage;

  const TripState({
    required this.status,
    required this.activeTripId,
    required this.distanceMeters,
    required this.errorMessage,
  });

  factory TripState.initial() => const TripState(
    status: TripStatus.idle,
    activeTripId: null,
    distanceMeters: 0,
    errorMessage: null,
  );

  TripState copyWith({
    TripStatus? status,
    String? activeTripId,
    double? distanceMeters,
    String? errorMessage,
  }) {
    return TripState(
      status: status ?? this.status,
      activeTripId: activeTripId ?? this.activeTripId,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      errorMessage: errorMessage,
    );
  }
}

final tripControllerProvider = StateNotifierProvider<TripController, TripState>(
  (ref) {
    return TripController(ref);
  },
);

class TripController extends StateNotifier<TripState> {
  TripController(this.ref) : super(TripState.initial()) {
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    _restoreActiveTrip();
  }

  final Ref ref;
  Timer? _saveDebounce;
  Position? _startPosition;

  void _onTaskData(Object data) {
    try {
      if (data is Map && data["type"] == "distance") {
        final d = (data["distanceMeters"] as num?)?.toDouble() ?? 0.0;

        state = state.copyWith(
          status: TripStatus.tracking,
          distanceMeters: d,
          errorMessage: null,
        );

        final tripId = state.activeTripId;
        if (tripId == null) return;

        _saveDebounce?.cancel();
        _saveDebounce = Timer(const Duration(seconds: 2), () async {
          try {
            final ds = ref.read(tripLocalDatasourceProvider);
            final t = await ds.getById(tripId);
            if (t == null) return;

            await ds.upsert(
              t.copyWith(
                distanceMeters: d,
                updatedAt: DateTime.now(),
                isSynced: false,
              ),
            );
          } catch (_) {}
        });
      }
    } catch (e) {
      debugPrint("onTaskData error: $e");
    }
  }

  Future<void> _restoreActiveTrip() async {
    try {
      final ds = ref.read(tripLocalDatasourceProvider);
      final active = await ds.getActiveTrip();
      if (active == null) return;

      state = state.copyWith(
        status: TripStatus.tracking,
        activeTripId: active.id,
        distanceMeters: active.distanceMeters,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TripStatus.error,
        errorMessage: "Trip init failed: $e",
      );
    }
  }

  void clearError() {
    state = state.copyWith(status: TripStatus.idle, errorMessage: null);
    _restoreActiveTrip();
  }

  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied) return false;
    if (perm == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<void> startTrip({required String carId}) async {
    if (state.status == TripStatus.tracking) return;

    try {
      final notiPerm =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notiPerm != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }

      final ok = await _ensureLocationPermission();
      if (!ok) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: "Turn ON GPS and allow location permission.",
        );
        return;
      }

      final userId = (ref.read(currentUserIdProvider) ?? "").trim();
      if (userId.isEmpty) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: "User ID not found. Please login again.",
        );
        return;
      }

      final ds = ref.read(tripLocalDatasourceProvider);

      final existing = await ds.getActiveTrip();
      if (existing != null) {
        state = state.copyWith(
          status: TripStatus.tracking,
          activeTripId: existing.id,
          distanceMeters: existing.distanceMeters,
          errorMessage: null,
        );
        return;
      }

      final now = DateTime.now();
      final tripId = const Uuid().v4();

      try {
        _startPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        );
      } catch (_) {
        _startPosition = null;
      }

      await ds.upsert(
        TripHiveModel(
          id: tripId,
          userId: userId,
          carId: carId,
          startTime: now,
          endTime: null,
          distanceMeters: 0,
          isSynced: false,
          updatedAt: now,
        ),
      );

      await FlutterForegroundTask.startService(
        notificationTitle: "Wheels tracking trip",
        notificationText: "Trip running • Tap to open",
        callback: startTripTaskHandler,
      );

      FlutterForegroundTask.sendDataToTask({"type": "reset"});

      state = state.copyWith(
        status: TripStatus.tracking,
        activeTripId: tripId,
        distanceMeters: 0,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TripStatus.error,
        errorMessage: "Failed to start trip: $e",
      );
    }
  }

  Future<void> stopTrip() async {
    final tripId = state.activeTripId;
    if (tripId == null) return;

    state = state.copyWith(status: TripStatus.stopping);

    try {
      await FlutterForegroundTask.stopService();

      double finalDistance = state.distanceMeters;

      // Fallback for short trips that received no stream updates
      if (finalDistance <= 0 && _startPosition != null) {
        try {
          final endPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
            ),
          );

          if (endPosition.accuracy <= 50) {
            final fallbackDistance = Geolocator.distanceBetween(
              _startPosition!.latitude,
              _startPosition!.longitude,
              endPosition.latitude,
              endPosition.longitude,
            );

            if (fallbackDistance >= 1 && fallbackDistance <= 100000) {
              finalDistance = fallbackDistance;
            }
          }
        } catch (_) {}
      }

      final ds = ref.read(tripLocalDatasourceProvider);
      final t = await ds.getById(tripId);

      if (t != null) {
        await ds.upsert(
          t.copyWith(
            endTime: DateTime.now(),
            distanceMeters: finalDistance,
            updatedAt: DateTime.now(),
            isSynced: false,
          ),
        );
      }

      _startPosition = null;
      state = TripState.initial();
    } catch (e) {
      state = state.copyWith(
        status: TripStatus.error,
        errorMessage: "Failed to stop trip: $e",
      );
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    super.dispose();
  }
}
