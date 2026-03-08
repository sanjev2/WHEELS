import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/app/theme/color.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage_provider.dart';
import 'package:wheels_flutter/features/car/presentation/providers/car_provider.dart'; // ✅ your car providers (list mine)
import 'package:wheels_flutter/features/services/presentation/providers/service_provider.dart';
import 'package:wheels_flutter/features/services/presentation/state/service_state.dart';
import 'package:wheels_flutter/features/services/presentation/pages/package_detail_page.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  String? _activeCategory;
  bool _loadingCategory = true;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadActiveCarCategory(),
    );
  }

  Future<void> _loadActiveCarCategory() async {
    try {
      setState(() {
        _loadingCategory = true;
        _categoryError = null;
      });

      final activeCarId = ref.read(activeCarStorageProvider).getActiveCarId();
      if (activeCarId == null || activeCarId.isEmpty) {
        setState(() {
          _activeCategory = null;
          _loadingCategory = false;
        });
        return;
      }

      await ref.read(carViewModelProvider.notifier).loadMyCars();

      final carState = ref.read(carViewModelProvider);
      final car = carState.cars.where((c) => c.id == activeCarId).isNotEmpty
          ? carState.cars.firstWhere((c) => c.id == activeCarId)
          : null;

      if (car == null) {
        setState(() {
          _activeCategory = null;
          _loadingCategory = false;
        });
        return;
      }

      setState(() {
        _activeCategory = car.category;
        _loadingCategory = false;
      });

      await ref
          .read(servicesViewModelProvider.notifier)
          .loadPackages(car.category);
    } catch (e) {
      setState(() {
        _categoryError = e.toString();
        _loadingCategory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesViewModelProvider);

    if (_loadingCategory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categoryError != null) {
      return Center(child: Text(_categoryError!));
    }

    if (_activeCategory == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Text(
              "Please select a vehicle first.\nPackages will show based on your vehicle category.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }

    if (servicesState.status == ServicesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (servicesState.status == ServicesStatus.error) {
      return Center(
        child: Text(servicesState.error ?? "Failed to load packages"),
      );
    }

    final packages = servicesState.packages;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = packages[index];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PackageDetailPage(package: p)),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0E000000),
                  blurRadius: 14,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                if (p.description != null && p.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    p.description!,
                    style: const TextStyle(color: AppColors.textTertiary),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  "₹ ${p.price}",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (p.durationMins != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Duration: ${p.durationMins} mins",
                    style: const TextStyle(color: AppColors.textTertiary),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "Oil Types: ${p.engineOilTypes.isEmpty ? "—" : p.engineOilTypes.join(", ")}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
