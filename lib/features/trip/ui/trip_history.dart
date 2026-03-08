import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/trip/logic/trip_provider.dart';

class TripHistoryPage extends ConsumerWidget {
  const TripHistoryPage({super.key});

  String _fmt(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")} "
        "${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: AppBar(
        title: const Text("Trip History"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(tripHistoryProvider);
              ref.invalidate(tripStatsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (trips) {
          final completed = trips.where((t) => t.endTime != null).toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime));

          if (completed.isEmpty) {
            return const Center(child: Text("No trips found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: completed.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final t = completed[i];
              final km = t.distanceMeters / 1000.0;

              return _TripCard(
                title: "Trip • ${km.toStringAsFixed(2)} km",
                subtitle:
                    "Start: ${_fmt(t.startTime)}\nEnd: ${_fmt(t.endTime!)}",
                trailing: t.isSynced ? "Synced" : "Pending",
                trailingColor: t.isSynced ? Colors.green : Colors.orange,
              );
            },
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final Color trailingColor;

  const _TripCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.route_rounded, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.black.withOpacity(0.65)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: TextStyle(fontWeight: FontWeight.w800, color: trailingColor),
          ),
        ],
      ),
    );
  }
}
