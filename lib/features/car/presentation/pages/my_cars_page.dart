import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage_provider.dart';

import 'package:wheels_flutter/features/car/presentation/providers/car_provider.dart';
import 'package:wheels_flutter/features/car/presentation/state/car_state.dart';

import '../../../../app/theme/color.dart';
import 'add_car_page.dart';
import 'edit_car_page.dart';

class MyCarsPage extends ConsumerStatefulWidget {
  const MyCarsPage({super.key});

  @override
  ConsumerState<MyCarsPage> createState() => _MyCarsPageState();
}

class _MyCarsPageState extends ConsumerState<MyCarsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carViewModelProvider.notifier).loadMyCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carViewModelProvider);

    // NOTE: using ref.watch to rebuild when storage changes (if it’s a Provider)
    final storage = ref.watch(activeCarStorageProvider);
    final activeCarId = storage.getActiveCarId();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "My Vehicles",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddCarPage()),
          );
          if (added == true) {
            ref.read(carViewModelProvider.notifier).loadMyCars();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(state, activeCarId),
    );
  }

  Widget _buildBody(CarState state, String? activeCarId) {
    if (state.status == CarStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CarStatus.error) {
      return Center(child: Text(state.errorMessage ?? "Something went wrong"));
    }

    if (state.cars.isEmpty) {
      return const Center(
        child: Text(
          "No vehicles found. Add one!",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: state.cars.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final car = state.cars[index];

        final id = (car.id ?? "").trim();
        final isActive = id.isNotEmpty && id == (activeCarId ?? "");

        final make = (car.make ?? "").trim();
        final model = (car.model ?? "").trim();
        final year = car.year?.toString() ?? "-";
        final category = (car.category ?? "-").trim().isEmpty
            ? "-"
            : (car.category ?? "-").trim();
        final fuel = (car.fuelType ?? "-").trim().isEmpty
            ? "-"
            : (car.fuelType ?? "-").trim();
        final plate = (car.licensePlate ?? "-").trim().isEmpty
            ? "-"
            : (car.licensePlate ?? "-").trim();

        return _CarCard(
          isActive: isActive,
          title:
              "${make.isEmpty ? 'Vehicle' : make} ${model.isEmpty ? '' : model} ($year)"
                  .trim(),
          subtitle: "$category • $fuel • $plate",
          onTap: id.isEmpty
              ? null
              : () async {
                  await ref.read(activeCarStorageProvider).setActiveCarId(id);
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Selected: ${make.isEmpty ? "Vehicle" : make} ${model}",
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },
          onEdit: id.isEmpty
              ? null
              : () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => EditCarPage(car: car)),
                  );

                  if (updated == true) {
                    ref.read(carViewModelProvider.notifier).loadMyCars();
                  }
                },
          onDelete: id.isEmpty ? null : () => _confirmDelete(context, id),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    if (id.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Vehicle?"),
        content: const Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      final success = await ref
          .read(carViewModelProvider.notifier)
          .deleteCar(id);
      if (!mounted) return;

      final active = ref.read(activeCarStorageProvider).getActiveCarId();
      if (active == id) {
        await ref.read(activeCarStorageProvider).clearActiveCarId();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Deleted" : "Delete failed")),
      );

      // optional refresh after delete
      ref.read(carViewModelProvider.notifier).loadMyCars();
    }
  }
}

// ----------------------------
// ✅ Clean & Elegant card widget
// ----------------------------
class _CarCard extends StatelessWidget {
  const _CarCard({
    required this.isActive,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isActive;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.primaryGreen : AppColors.borderLight,
            width: isActive ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.18),
                ),
              ),
              child: Icon(
                isActive ? Icons.check_circle : Icons.directions_car_outlined,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: "Edit",
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryGreen.withOpacity(0.9),
                  ),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: "Delete",
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFDC2626),
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
