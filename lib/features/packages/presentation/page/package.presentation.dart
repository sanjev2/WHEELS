import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import 'package:wheels_flutter/features/booking/presentation/providers/booking_provoder.dart';
import 'package:wheels_flutter/features/packages/presentation/provider/package_provider.dart';
import 'package:wheels_flutter/features/provider/presentation/page/select_provider_page.dart';
import '../state/package_state.dart';

class PackagesPage extends ConsumerStatefulWidget {
  final String carId;
  final String category;

  const PackagesPage({super.key, required this.carId, required this.category});

  @override
  ConsumerState<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends ConsumerState<PackagesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(packageViewModelProvider.notifier).loadPackages(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: _PackagesAppBar(
        title: "Packages",
        subtitle: widget.category,
        onBack: () => Navigator.maybePop(context),
      ),
      body: _body(context, state),
    );
  }

  Widget _body(BuildContext context, PackageState state) {
    if (state.status == PackageStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PackageStatus.error) {
      return _StateView(
        icon: Icons.wifi_off_rounded,
        title: "Couldn’t load packages",
        subtitle: state.errorMessage ?? "Please try again.",
        actionText: "Retry",
        onAction: () => ref
            .read(packageViewModelProvider.notifier)
            .loadPackages(widget.category),
      );
    }

    final packages = state.packages;
    if (packages.isEmpty) {
      return const _StateView(
        icon: Icons.inventory_2_outlined,
        title: "No packages found",
        subtitle: "Try again later or change category.",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      itemCount: packages.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) {
          return _TopSummary(category: widget.category, total: packages.length);
        }

        final p = packages[i - 1];

        return _PackageCard(
          title: p.title,
          category: p.category,
          price: p.price,
          durationMins: p.durationMins ?? 0,
          oilCount: p.engineOilTypes.length,
          addonCount: p.addons.length,
          onTap: () async {
            final draft = BookingDraft(
              carId: widget.carId,
              category: widget.category,
              packageId: p.id,
              packageTitle: p.title,
              basePrice: p.price,
              durationMins: p.durationMins ?? 0,
              selectedOilType: null,
              selectedAddons: const [],
              providerId: null,
              providerName: null,
            );

            ref.read(bookingViewModelProvider.notifier).startDraft(draft);

            final ok = await _showOilAndAddonSheet(
              context: context,
              oilTypes: p.engineOilTypes,
              addons: p.addons,
              packageTitle: p.title,
              basePrice: p.price,
              durationMins: p.durationMins ?? 0,
            );

            if (ok != true) return;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProviderSelectPage(category: widget.category),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _showOilAndAddonSheet({
    required BuildContext context,
    required List<String> oilTypes,
    required List<String> addons,
    required String packageTitle,
    required num basePrice,
    required int durationMins,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _OilAddonStepperSheet(
          oilTypes: oilTypes,
          addons: addons,
          packageTitle: packageTitle,
          basePrice: basePrice,
          durationMins: durationMins,
        );
      },
    );
  }
}

class _PackagesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PackagesAppBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: onBack,
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: _Ui.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: _Ui.subText,
            ),
          ),
        ],
      ),
      actions: const [SizedBox(width: 48)],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Ui.gradA.withOpacity(0.10),
              Colors.white.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ui {
  static const bg = Color(0xFFF5F7F7);
  static const card = Colors.white;

  // Premium “emerald” + “teal” gradient (safe, elegant)
  static const gradA = Color(0xFF16A34A);
  static const gradB = Color(0xFF10B981);

  static const text = Color(0xFF0B1220);
  static const subText = Color(0xFF6B7280);
  static const border = Color(0x14000000); // 8% black

  static const radius = 18.0;
}

class _TopSummary extends StatelessWidget {
  final String category;
  final int total;

  const _TopSummary({required this.category, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Ui.card,
        borderRadius: BorderRadius.circular(_Ui.radius),
        border: Border.all(color: _Ui.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_Ui.gradA, _Ui.gradB],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose a package",
                  style: TextStyle(
                    color: _Ui.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$total available • $category",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _Ui.subText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String title;
  final String category;
  final num price;
  final int durationMins;
  final int oilCount;
  final int addonCount;
  final VoidCallback onTap;

  const _PackageCard({
    required this.title,
    required this.category,
    required this.price,
    required this.durationMins,
    required this.oilCount,
    required this.addonCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Ui.card,
        borderRadius: BorderRadius.circular(_Ui.radius),
        border: Border.all(color: _Ui.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_Ui.radius),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _Ui.border),
                      ),
                      child: const Icon(
                        Icons.build_circle_outlined,
                        color: _Ui.text,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _Ui.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              height: 1.18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _Ui.subText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0x770B1220),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _InfoBadge(
                        icon: Icons.timer_outlined,
                        label: "Duration",
                        value: "$durationMins min",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoBadge(
                        icon: Icons.local_gas_station_outlined,
                        label: "Oil",
                        value: "$oilCount options",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoBadge(
                        icon: Icons.extension_outlined,
                        label: "Add-ons",
                        value: "$addonCount",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _Ui.gradA.withOpacity(0.10),
                        _Ui.gradB.withOpacity(0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _Ui.gradB.withOpacity(0.22)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Starting from",
                        style: TextStyle(
                          color: _Ui.subText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Rs ${price.toString()}",
                        style: const TextStyle(
                          color: _Ui.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Ui.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _Ui.text.withOpacity(0.75)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _Ui.subText,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _Ui.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.8,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OilAddonStepperSheet extends ConsumerStatefulWidget {
  final List<String> oilTypes;
  final List<String> addons;
  final String packageTitle;
  final num basePrice;
  final int durationMins;

  const _OilAddonStepperSheet({
    required this.oilTypes,
    required this.addons,
    required this.packageTitle,
    required this.basePrice,
    required this.durationMins,
  });

  @override
  ConsumerState<_OilAddonStepperSheet> createState() =>
      _OilAddonStepperSheetState();
}

class _OilAddonStepperSheetState extends ConsumerState<_OilAddonStepperSheet> {
  int _step = 0;
  String? _selectedOil;
  final Set<String> _selectedAddons = {};

  void _goStep(int s) => setState(() => _step = s);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;
    final progress = _step == 0 ? 0.5 : 1.0;

    final needsOil = widget.oilTypes.isNotEmpty;
    final canGoNext = !needsOil || _selectedOil != null;

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 36,
              offset: const Offset(0, -14),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),

            // Gradient header with compact summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_Ui.gradA, _Ui.gradB],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.packageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${widget.durationMins} min • Rs ${widget.basePrice}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Pill(
                      text: "Step ${_step + 1}/2",
                      bg: Colors.white.withOpacity(0.18),
                      fg: Colors.white,
                      border: Colors.white.withOpacity(0.24),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: Colors.black.withOpacity(0.07),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _Ui.gradB.withOpacity(0.95),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tabs (better sizing + placement)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SegmentedTabs(
                index: _step,
                onChanged: (v) {
                  if (v == 0) _goStep(0);
                  if (v == 1 && canGoNext) _goStep(1);
                },
                left: "Engine Oil",
                right: "Add-ons",
                rightEnabled: canGoNext,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(anim);
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: _step == 0
                    ? _oilStep(key: const ValueKey("oil"))
                    : _addonStep(key: const ValueKey("addons")),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  if (_step == 1)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _Ui.text,
                          side: BorderSide(color: _Ui.border.withOpacity(0.9)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => _goStep(0),
                        child: const Text(
                          "Back",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  if (_step == 1) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        backgroundColor: _Ui.gradA,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_step == 0) {
                          if (needsOil && _selectedOil == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select oil type"),
                              ),
                            );
                            return;
                          }
                          if (_selectedOil != null) {
                            ref
                                .read(bookingViewModelProvider.notifier)
                                .setOilType(_selectedOil!);
                          }
                          _goStep(1);
                        } else {
                          ref
                              .read(bookingViewModelProvider.notifier)
                              .setAddons(_selectedAddons.toList());
                          Navigator.pop(context, true);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _step == 0 ? "Next" : "Continue",
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _oilStep({Key? key}) {
    final oils = widget.oilTypes;

    if (oils.isEmpty) {
      return const _SheetEmpty(
        icon: Icons.oil_barrel_outlined,
        title: "No oil types",
        subtitle: "This package has no oil options. You can continue.",
      );
    }

    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select one engine oil",
            style: TextStyle(
              color: _Ui.text,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              itemCount: oils.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.15,
              ),
              itemBuilder: (context, i) {
                final oil = oils[i];
                final selected = _selectedOil == oil;
                return _PremiumSelectCard(
                  title: oil,
                  selected: selected,
                  onTap: () => setState(() => _selectedOil = oil),
                  leadingIcon: Icons.local_gas_station_outlined,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (_selectedOil != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _Ui.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: _Ui.gradA.withOpacity(0.95),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Selected: $_selectedOil",
                      style: const TextStyle(
                        color: _Ui.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _addonStep({Key? key}) {
    final addons = widget.addons;

    if (addons.isEmpty) {
      return const _SheetEmpty(
        icon: Icons.extension_outlined,
        title: "No add-ons available",
        subtitle: "You can continue without add-ons.",
      );
    }

    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Choose add-ons (optional)",
                  style: TextStyle(
                    color: _Ui.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ),
              _Pill(
                text: "${_selectedAddons.length} selected",
                bg: const Color(0xFFF8FAFC),
                fg: _Ui.text.withOpacity(0.75),
                border: _Ui.border,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: addons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = addons[i];
                final selected = _selectedAddons.contains(a);
                return _AddonPremiumTile(
                  title: a,
                  selected: selected,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedAddons.remove(a);
                      } else {
                        _selectedAddons.add(a);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final String left;
  final String right;
  final bool rightEnabled;

  const _SegmentedTabs({
    required this.index,
    required this.onChanged,
    required this.left,
    required this.right,
    required this.rightEnabled,
  });

  @override
  Widget build(BuildContext context) {
    Widget seg(String text, bool active, bool enabled, int idx) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? () => onChanged(idx) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white
                  : (enabled
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? _Ui.gradB.withOpacity(0.35)
                    : _Ui.border.withOpacity(0.9),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: _Ui.gradB.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: enabled
                      ? (active ? _Ui.text : _Ui.text.withOpacity(0.65))
                      : _Ui.text.withOpacity(0.35),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Ui.border),
      ),
      child: Row(
        children: [
          seg(left, index == 0, true, 0),
          const SizedBox(width: 8),
          seg(right, index == 1, rightEnabled, 1),
        ],
      ),
    );
  }
}

class _PremiumSelectCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final IconData leadingIcon;

  const _PremiumSelectCard({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _Ui.gradA.withOpacity(0.95),
                  _Ui.gradB.withOpacity(0.95),
                ],
              )
            : null,
        color: selected ? null : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? Colors.transparent : _Ui.border),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: _Ui.gradB.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.20)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withOpacity(0.20)
                          : _Ui.border,
                    ),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: 18,
                    color: selected ? Colors.white : _Ui.text.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : _Ui.text,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withOpacity(0.2)
                          : _Ui.border,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: _Ui.gradA.withOpacity(0.95),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddonPremiumTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _AddonPremiumTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? _Ui.gradB.withOpacity(0.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? _Ui.gradB.withOpacity(0.25) : _Ui.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 26,
                  width: 26,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_Ui.gradA, _Ui.gradB],
                          )
                        : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : _Ui.border.withOpacity(0.9),
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: _Ui.text.withOpacity(0.55),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _Ui.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _Pill(
                  text: selected ? "Added" : "Add",
                  bg: selected
                      ? _Ui.gradA.withOpacity(0.12)
                      : Colors.white.withOpacity(0.9),
                  fg: selected ? _Ui.gradA : _Ui.text.withOpacity(0.65),
                  border: selected
                      ? _Ui.gradA.withOpacity(0.20)
                      : _Ui.border.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color border;

  const _Pill({
    required this.text,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: fg),
      ),
    );
  }
}

class _SheetEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SheetEmpty({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _Ui.border),
              ),
              child: Icon(icon, size: 30, color: _Ui.text.withOpacity(0.65)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: _Ui.text,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _Ui.subText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _StateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 110),
        Center(
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _Ui.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: _Ui.text.withOpacity(0.7)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _Ui.text,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _Ui.subText,
              fontWeight: FontWeight.w700,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: _Ui.gradA,
                foregroundColor: Colors.white,
              ),
              onPressed: onAction,
              child: Text(
                actionText!,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
