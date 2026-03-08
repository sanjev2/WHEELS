import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/app/theme/color.dart';
import 'package:wheels_flutter/core/constants/app_constants.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage_provider.dart';

import 'package:wheels_flutter/features/auth/presentation/pages/login_pages.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';

import 'package:wheels_flutter/features/order/presentation/pages/my_order_page.dart';
import 'package:wheels_flutter/features/packages/presentation/page/package.presentation.dart';
import 'package:wheels_flutter/features/profile/profile_page.dart'
    hide AppColors;

import 'package:wheels_flutter/features/car/presentation/pages/my_cars_page.dart';
import 'package:wheels_flutter/features/car/presentation/providers/car_provider.dart';
import 'package:wheels_flutter/features/car/presentation/state/car_state.dart';
import 'package:wheels_flutter/features/car/domain/entities/car_entity.dart';

import 'package:wheels_flutter/features/trip/presentation/controller/trip_controller.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  void _goToTab(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.authEntity;
    if (currentUser == null) return const LoginPage();

    final pages = <Widget>[
      DashboardHome(onGoToTab: _goToTab),
      const _ServicesTab(),
      const MyOrdersPage(),
      const ProfilePagePro(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _PremiumBottomNav(
        index: _selectedIndex,
        onChanged: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _PremiumBottomNav({required this.index, required this.onChanged});

  static const _activeGrad = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem(
        label: "Home",
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      _NavItem(
        label: "Services",
        icon: Icons.design_services_outlined,
        activeIcon: Icons.design_services_rounded,
      ),
      _NavItem(
        label: "Orders",
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
      ),
      _NavItem(
        label: "Profile",
        icon: Icons.person_outline,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.06)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final it = items[i];
              final active = i == index;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            gradient: active ? _activeGrad : null,
                            color: active ? null : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFF16A34A).withOpacity(0.25)
                                  : Colors.black.withOpacity(0.06),
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF16A34A,
                                      ).withOpacity(0.16),
                                      blurRadius: 14,
                                      offset: const Offset(0, 10),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            active ? it.activeIcon : it.icon,
                            size: 19,
                            color: active ? Colors.white : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            fontSize: 11.0,
                            height: 1.0,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? const Color(0xFF0B1220)
                                : Colors.black45,
                          ),
                          child: Text(it.label, maxLines: 1),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          height: 3,
                          width: active ? 18 : 6,
                          decoration: BoxDecoration(
                            gradient: active ? _activeGrad : null,
                            color: active ? null : Colors.black12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _ServicesTab extends ConsumerWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(activeCarStorageProvider);
    final carId = storage.getActiveCarId();

    if (carId == null || carId.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F7),
        appBar: AppBar(
          title: const Text(
            "Services",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        body: _PremiumEmptyState(
          icon: Icons.directions_car_outlined,
          title: "Select an active car",
          subtitle:
              "Choose a vehicle first so we can show packages that match your car category.",
          actionText: "Select Car",
          onAction: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyCarsPage()),
            );
          },
        ),
      );
    }

    final carState = ref.watch(carViewModelProvider);

    CarEntity? activeCar;
    for (final c in carState.cars) {
      if ((c.id ?? "") == carId) {
        activeCar = c;
        break;
      }
    }

    final category = (activeCar?.category.trim().isNotEmpty ?? false)
        ? activeCar!.category
        : "general";

    return PackagesPage(carId: carId, category: category);
  }
}

class DashboardHome extends ConsumerStatefulWidget {
  final void Function(int index) onGoToTab;

  const DashboardHome({super.key, required this.onGoToTab});

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  static const _accentGrad = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  bool _autoActiveDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(carViewModelProvider.notifier).loadMyCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool small = width < 360;

    final authState = ref.watch(authViewModelProvider);
    final authUser = authState.authEntity;

    final currentUser = ref.watch(currentUserProvider);
    final carState = ref.watch(carViewModelProvider);

    final storage = ref.watch(activeCarStorageProvider);
    final activeCarId = storage.getActiveCarId();

    final double vehicleHeight = small ? 330 : (width < 600 ? 320 : 340);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async =>
            ref.read(carViewModelProvider.notifier).loadMyCars(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(width * 0.045, 14, width * 0.045, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                name: currentUser?.name ?? 'Admin',
                onLogout: () async {
                  await ref.read(authViewModelProvider.notifier).logout();
                },
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Text(
                    "Your Vehicles",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: _accentGrad,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16A34A).withOpacity(0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyCarsPage()),
                        );
                        if (!mounted) return;
                        ref.read(carViewModelProvider.notifier).loadMyCars();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        "Manage",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: vehicleHeight,
                child: _buildCarsSection(
                  context: context,
                  state: carState,
                  activeCarId: activeCarId,
                ),
              ),

              const SizedBox(height: 14),

              _TripSection(
                user: authUser ?? currentUser,
                activeCarId: activeCarId,
              ),

              const SizedBox(height: 14),

              _SearchBar(onTap: () => widget.onGoToTab(1)),
              const SizedBox(height: 16),

              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final maxW = constraints.maxWidth;
                  final int columns = maxW >= 560 ? 3 : (maxW >= 360 ? 2 : 1);
                  final itemWidth = columns == 1
                      ? maxW
                      : (maxW - spacing * (columns - 1)) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _QuickActionCard(
                          icon: Icons.design_services_outlined,
                          title: 'Services',
                          subtitle: 'Explore packages',
                          onTap: () => widget.onGoToTab(1),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _QuickActionCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Orders',
                          subtitle: 'My bookings',
                          onTap: () => widget.onGoToTab(2),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _QuickActionCard(
                          icon: Icons.directions_car_outlined,
                          title: 'My Vehicles',
                          subtitle: 'Manage cars',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyCarsPage(),
                              ),
                            );
                            if (!mounted) return;
                            ref
                                .read(carViewModelProvider.notifier)
                                .loadMyCars();
                          },
                        ),
                      ),
                      SizedBox(
                        width: maxW,
                        child: _QuickActionCard(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          subtitle: 'Manage account',
                          onTap: () => widget.onGoToTab(3),
                          wide: true,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              Text(
                'Recommended for you',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              _RecommendationTile(
                icon: Icons.local_offer_outlined,
                title: 'Seasonal Service Offer',
                subtitle: 'Save on maintenance this week',
                onTap: () => widget.onGoToTab(1),
              ),
              const SizedBox(height: 10),
              _RecommendationTile(
                icon: Icons.receipt_long_outlined,
                title: 'Track your orders',
                subtitle: 'View your order status',
                onTap: () => widget.onGoToTab(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarsSection({
    required BuildContext context,
    required CarState state,
    required String? activeCarId,
  }) {
    if (state.status == CarStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CarStatus.error) {
      return _PremiumEmptyState(
        icon: Icons.error_outline_rounded,
        title: "Couldn’t load vehicles",
        subtitle: state.errorMessage ?? "Please try again.",
        actionText: "Retry",
        onAction: () => ref.read(carViewModelProvider.notifier).loadMyCars(),
      );
    }

    final cars = state.cars;
    if (cars.isEmpty) {
      return _NoCarsCard(
        onAddCar: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyCarsPage()),
          );
          if (!mounted) return;
          ref.read(carViewModelProvider.notifier).loadMyCars();
        },
      );
    }

    if (!_autoActiveDone) {
      _autoActiveDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final storage = ref.read(activeCarStorageProvider);
        final current = storage.getActiveCarId();
        if (current == null || current.isEmpty) {
          final firstId = (cars.first.id ?? "").trim();
          if (firstId.isNotEmpty) {
            await storage.setActiveCarId(firstId);
          }
        }
      });
    }

    return _RegisteredVehiclesSlider(
      cars: cars,
      activeCarId: activeCarId,
      onCarSelected: (carId) async {
        final storage = ref.read(activeCarStorageProvider);
        await storage.setActiveCarId(carId);
      },
    );
  }
}

class _TripSection extends ConsumerWidget {
  final dynamic user;
  final String? activeCarId;

  const _TripSection({required this.user, required this.activeCarId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripControllerProvider);
    final isTracking = trip.status == TripStatus.tracking;
    final km = trip.distanceMeters / 1000.0;

    final titleStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    final subStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary.withOpacity(0.92),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
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
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Icon(
                  isTracking ? Icons.route_rounded : Icons.play_arrow_rounded,
                  color: const Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTracking ? "Trip running" : "Trip tracking",
                      style: titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTracking
                          ? "Distance • ${km.toStringAsFixed(2)} km"
                          : "Track distance in the background",
                      style: subStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 38,
                width: 92,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: isTracking
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () async {
                    if (isTracking) {
                      await ref
                          .read(tripControllerProvider.notifier)
                          .stopTrip();
                      return;
                    }

                    if (activeCarId == null || activeCarId!.isEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Select an active car first."),
                        ),
                      );
                      return;
                    }

                    await ref
                        .read(tripControllerProvider.notifier)
                        .startTrip(carId: activeCarId!);
                  },
                  child: Text(isTracking ? "Stop" : "Start"),
                ),
              ),
            ],
          ),
          if (trip.status == TripStatus.error) ...[
            const SizedBox(height: 10),
            _SoftInlineError(
              message: trip.errorMessage ?? "Trip error",
              onRetry: () =>
                  ref.read(tripControllerProvider.notifier).clearError(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SoftInlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SoftInlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.72),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Retry",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisteredVehiclesSlider extends StatefulWidget {
  final List<CarEntity> cars;
  final String? activeCarId;
  final Future<void> Function(String carId) onCarSelected;

  const _RegisteredVehiclesSlider({
    required this.cars,
    required this.activeCarId,
    required this.onCarSelected,
  });

  @override
  State<_RegisteredVehiclesSlider> createState() =>
      _RegisteredVehiclesSliderState();
}

class _RegisteredVehiclesSliderState extends State<_RegisteredVehiclesSlider> {
  late final PageController _controller;

  static const _gradGreen = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _gradTeal = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient _cardGradient(int index) =>
      index.isEven ? _gradGreen : _gradTeal;

  @override
  void initState() {
    super.initState();

    final initialIndex = _initialPageIndex();
    _controller = PageController(
      viewportFraction: 0.92,
      initialPage: initialIndex,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.cars.isEmpty) return;

      final carId = (widget.cars[initialIndex].id ?? "").trim();
      if (carId.isNotEmpty) {
        await widget.onCarSelected(carId);
      }
    });
  }

  int _initialPageIndex() {
    final active = (widget.activeCarId ?? "").trim();
    if (active.isEmpty) return 0;
    final idx = widget.cars.indexWhere((c) => (c.id ?? "").trim() == active);
    return idx >= 0 ? idx : 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool small = width < 360;

    final double carHeight = small ? 118 : (width < 600 ? 140 : 160);
    final double topMargin = small ? 56 : 64;
    final double imageTop = small ? -16 : -18;
    final double sidePadding = small ? 16 : 20;
    final double bottomPadding = small ? 16 : 20;
    final double topPadding = (carHeight * 0.62).clamp(78, 100).toDouble();
    final double titleGap = small ? 8 : 10;
    final double imageWidthFactor = small ? 0.92 : 0.88;

    return PageView.builder(
      controller: _controller,
      itemCount: widget.cars.length,
      clipBehavior: Clip.none,
      onPageChanged: (index) async {
        final carId = (widget.cars[index].id ?? "").trim();
        if (carId.isNotEmpty) await widget.onCarSelected(carId);
      },
      itemBuilder: (context, index) {
        final car = widget.cars[index];

        final name = "${(car.make ?? "").trim()} ${(car.model ?? "").trim()}"
            .trim();
        final category = (car.category ?? "-").trim().isEmpty
            ? "-"
            : (car.category ?? "-").trim();
        final plate = (car.licensePlate ?? "-").trim().isEmpty
            ? "-"
            : (car.licensePlate ?? "-").trim();

        final purchasedOn = _formatDate(car.boughtDate);
        final yearsOfUse = _yearsOfUse(car.boughtDate);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: topMargin),
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  topPadding,
                  sidePadding,
                  bottomPadding,
                ),
                decoration: BoxDecoration(
                  gradient: _cardGradient(index),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withOpacity(0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? "My Vehicle" : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: small ? 16 : null,
                      ),
                    ),
                    SizedBox(height: titleGap),
                    _infoRow('Category', category, small: small),
                    _infoRow('License Plate', plate, small: small),
                    _infoRow('Purchased on', purchasedOn, small: small),
                    _infoRow('Years of use', yearsOfUse, small: small),
                  ],
                ),
              ),
              Positioned(
                top: imageTop,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: SizedBox(
                    height: carHeight,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: imageWidthFactor,
                        child: Image.asset(
                          AppConstants.carImage,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return "-";
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final m = months[(d.month - 1).clamp(0, 11)];
    return "$m ${d.day} ${d.year}";
  }

  String _yearsOfUse(DateTime? bought) {
    if (bought == null) return "-";
    final now = DateTime.now();
    if (bought.isAfter(now)) return "0 yrs 0 months";

    int months = (now.year - bought.year) * 12 + (now.month - bought.month);
    if (now.day < bought.day) months -= 1;
    if (months < 0) months = 0;

    final yrs = months ~/ 12;
    final rem = months % 12;
    return "$yrs yrs $rem months";
  }

  Widget _infoRow(String label, String value, {required bool small}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: small ? 3.0 : 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.80),
                fontSize: small ? 12 : 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: small ? 12 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoCarsCard extends StatelessWidget {
  final VoidCallback onAddCar;
  const _NoCarsCard({required this.onAddCar});

  static const _activeGrad = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                gradient: _activeGrad,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "No registered vehicles yet",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first vehicle to see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
                onPressed: onAddCar,
                child: const Text(
                  "Add / Select Vehicle",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _PremiumEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 110),
        Center(
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.black.withOpacity(0.7)),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onAction,
              child: Text(
                actionText!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;

  const _Header({required this.name, required this.onLogout});

  static const _headerGrad = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: _headerGrad,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 12),
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
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              color: Colors.white,
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
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
            const Icon(Icons.search, color: AppColors.textTertiary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Search services, orders...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(Icons.tune, color: AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool wide;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.wide = false,
  });

  static const _activeGrad = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
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
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: _activeGrad,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: child);
  }
}

class _RecommendationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RecommendationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const _activeGrad = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
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
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: _activeGrad,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white),
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
