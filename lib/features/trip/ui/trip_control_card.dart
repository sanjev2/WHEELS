import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/trip/presentation/controller/trip_controller.dart';
import 'package:wheels_flutter/features/trip/logic/trip_provider.dart';

import '../../../app/theme/color.dart';
import '../../../core/services/storage/active_car_storage_provider.dart';

class TripControlCard extends ConsumerWidget {
  const TripControlCard({super.key});

  static const _gradGreen = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripControllerProvider);

    if (trip.status == TripStatus.error) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                trip.errorMessage ?? "Trip error",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () =>
                  ref.read(tripControllerProvider.notifier).clearError(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final storage = ref.watch(activeCarStorageProvider);
    final activeCarId = storage.getActiveCarId();

    final isTracking = trip.status == TripStatus.tracking;
    final km = trip.distanceMeters / 1000.0;
    final kmText = km.toStringAsFixed(2);

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              gradient: _gradGreen,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withOpacity(0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: Icon(
                    isTracking ? Icons.route_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTracking ? "Trip in progress" : "Start a trip",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTracking
                            ? "Distance: $kmText km"
                            : "Track distance in background",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  width: 96,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      if (isTracking) {
                        await ref
                            .read(tripControllerProvider.notifier)
                            .stopTrip();

                        ref.invalidate(tripStatsProvider);
                        ref.invalidate(tripHistoryProvider);
                        return;
                      }

                      if (activeCarId == null || activeCarId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Select an active car first."),
                          ),
                        );
                        return;
                      }

                      await ref
                          .read(tripControllerProvider.notifier)
                          .startTrip(carId: activeCarId);

                      ref.invalidate(tripStatsProvider);
                      ref.invalidate(tripHistoryProvider);
                    },
                    child: Text(
                      isTracking ? "Stop" : "Start",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 14,
            top: -18,
            child: Opacity(
              opacity: 0.18,
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
