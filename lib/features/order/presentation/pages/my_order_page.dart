import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/order/presentation/provider/order_provider.dart';
import '../../../../app/theme/color.dart';
import '../state/order_state.dart';

class MyOrdersPage extends ConsumerStatefulWidget {
  const MyOrdersPage({super.key});

  @override
  ConsumerState<MyOrdersPage> createState() => _MyOrdersPageState();
}

enum _OrderFilter { all, paid, inProgress, completed, cancelled, pending }

class _MyOrdersPageState extends ConsumerState<MyOrdersPage> {
  _OrderFilter _filter = _OrderFilter.all;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersViewModelProvider.notifier).loadMyOrders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(ordersViewModelProvider.notifier).loadMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _OrdersAppBar(
        searchCtrl: _searchCtrl,
        onBack: () => Navigator.maybePop(context),
        onRefresh: _refresh,
        onClearSearch: () {
          _searchCtrl.clear();
          setState(() {});
        },
        onChangedSearch: (_) => setState(() {}),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state) {
    if (state.status == OrderStatusUi.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == OrderStatusUi.error) {
      return _StateView(
        icon: Icons.wifi_off_rounded,
        title: "Couldn’t load your orders",
        subtitle:
            state.errorMessage ?? "Please check your connection and try again.",
        actionText: "Retry",
        onAction: _refresh,
      );
    }

    // ---- Derived UI lists (filter + search) ----
    final q = _searchCtrl.text.trim().toLowerCase();

    final filtered = state.orders.where((o) {
      final statusOk = _matchesFilter(o.status, _filter);
      if (!statusOk) return false;

      if (q.isEmpty) return true;

      final hay = [
        o.packageTitle,
        o.category,
        o.providerName,
        o.status,
      ].join(" ").toLowerCase();

      return hay.contains(q);
    }).toList();

    // ---- Counts for summary ----
    final total = state.orders.length;
    final countPaid = state.orders.where((o) => _isPaidLike(o.status)).length;
    final countInProgress = state.orders
        .where((o) => o.status == "IN_PROGRESS")
        .length;
    final countCompleted = state.orders
        .where((o) => o.status == "COMPLETED")
        .length;

    if (total == 0) {
      return const _StateView(
        icon: Icons.receipt_long_rounded,
        title: "No orders yet",
        subtitle: "When you place an order, it will appear here.",
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        _TopSummary(
          total: total,
          paid: countPaid,
          inProgress: countInProgress,
          completed: countCompleted,
        ),
        const SizedBox(height: 12),
        _FilterRow(
          value: _filter,
          onChanged: (v) => setState(() => _filter = v),
        ),
        const SizedBox(height: 12),
        if (q.isNotEmpty)
          _InlineHint(
            icon: Icons.search_rounded,
            text: "Showing results for “${_searchCtrl.text.trim()}”",
            actionText: "Clear",
            onAction: () {
              _searchCtrl.clear();
              setState(() {});
            },
          ),
        if (filtered.isEmpty) ...[
          const SizedBox(height: 40),
          _StateView(
            icon: Icons.manage_search_rounded,
            title: "No matching orders",
            subtitle: "Try changing filters or clearing the search.",
            actionText: "Clear filters",
            onAction: () => setState(() {
              _filter = _OrderFilter.all;
              _searchCtrl.clear();
            }),
          ),
        ] else ...[
          const SizedBox(height: 4),
          ...List.generate(filtered.length, (idx) {
            final o = filtered[idx];
            final meta = _statusMeta(o.status);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderCard(
                title: o.packageTitle,
                subtitle: "${o.category} • ${o.providerName}",
                priceText: "Rs ${o.totalPrice.toStringAsFixed(0)}",
                dateText: _fmtDate(o.createdAt),
                statusLabel: meta.label,
                statusBg: meta.bg,
                statusFg: meta.fg,
                leadingColor: meta.dot,
                onTap: () {
                  // TODO: navigate to order details
                  // Navigator.push(...);
                },
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  bool _matchesFilter(String status, _OrderFilter f) {
    switch (f) {
      case _OrderFilter.all:
        return true;
      case _OrderFilter.paid:
        return _isPaidLike(status);
      case _OrderFilter.inProgress:
        return status == "IN_PROGRESS";
      case _OrderFilter.completed:
        return status == "COMPLETED";
      case _OrderFilter.cancelled:
        return status == "CANCELLED";
      case _OrderFilter.pending:
        return !(status == "PAID" ||
            status == "CONFIRMED" ||
            status == "IN_PROGRESS" ||
            status == "COMPLETED" ||
            status == "CANCELLED");
    }
  }

  bool _isPaidLike(String status) => status == "PAID" || status == "CONFIRMED";

  _StatusMeta _statusMeta(String status) {
    switch (status) {
      case "PAID":
      case "CONFIRMED":
        return _StatusMeta(
          label: status.replaceAll("_", " "),
          dot: AppColors.primaryGreen,
          bg: const Color(0xFFE8F6E8),
          fg: AppColors.primaryGreen,
        );
      case "IN_PROGRESS":
        return const _StatusMeta(
          label: "IN PROGRESS",
          dot: Color(0xFF2563EB),
          bg: Color(0xFFE8F0FF),
          fg: Color(0xFF2563EB),
        );
      case "COMPLETED":
        return const _StatusMeta(
          label: "COMPLETED",
          dot: Color(0xFF16A34A),
          bg: Color(0xFFEFFDF4),
          fg: Color(0xFF16A34A),
        );
      case "CANCELLED":
        return const _StatusMeta(
          label: "CANCELLED",
          dot: Color(0xFFDC2626),
          bg: Color(0xFFFFEAEA),
          fg: Color(0xFFDC2626),
        );
      default:
        return const _StatusMeta(
          label: "PENDING",
          dot: Color(0xFFD97706),
          bg: Color(0xFFFFF7E6),
          fg: Color(0xFFD97706),
        );
    }
  }

  String _fmtDate(DateTime d) {
    final y = d.year.toString().padLeft(4, "0");
    final m = d.month.toString().padLeft(2, "0");
    final day = d.day.toString().padLeft(2, "0");
    return "$y-$m-$day";
  }
}

/// -------------------- APP BAR --------------------

class _OrdersAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _OrdersAppBar({
    required this.onBack,
    required this.onRefresh,
    required this.searchCtrl,
    required this.onClearSearch,
    required this.onChangedSearch,
  });

  final VoidCallback onBack;
  final Future<void> Function() onRefresh;

  final TextEditingController searchCtrl;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onChangedSearch;

  @override
  Size get preferredSize => const Size.fromHeight(118);

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
      titleSpacing: 0,
      title: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "My Orders",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Order history & status",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: const [
        SizedBox(width: 48), // keeps title visually centered vs leading button
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGreen.withOpacity(0.12),
              Colors.white.withOpacity(0.0),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _SearchField(
            controller: searchCtrl,
            onClear: onClearSearch,
            onChanged: onChangedSearch,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onClear,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: Colors.black.withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: "Search orders (package, provider, status...)",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (hasText)
            IconButton(
              tooltip: "Clear",
              onPressed: onClear,
              icon: Icon(
                Icons.close_rounded,
                color: Colors.black.withOpacity(0.55),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TopSummary extends StatelessWidget {
  final int total;
  final int paid;
  final int inProgress;
  final int completed;

  const _TopSummary({
    required this.total,
    required this.paid,
    required this.inProgress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Orders",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$total total",
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: "Paid",
                value: paid,
                icon: Icons.verified_rounded,
                tint: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: "In Progress",
                value: inProgress,
                icon: Icons.timelapse_rounded,
                tint: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: "Completed",
                value: completed,
                icon: Icons.task_alt_rounded,
                tint: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$value",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.value, required this.onChanged});

  final _OrderFilter value;
  final ValueChanged<_OrderFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: "All",
            selected: value == _OrderFilter.all,
            onTap: () => onChanged(_OrderFilter.all),
          ),
          _FilterChip(
            label: "Paid",
            selected: value == _OrderFilter.paid,
            onTap: () => onChanged(_OrderFilter.paid),
          ),
          _FilterChip(
            label: "In Progress",
            selected: value == _OrderFilter.inProgress,
            onTap: () => onChanged(_OrderFilter.inProgress),
          ),
          _FilterChip(
            label: "Completed",
            selected: value == _OrderFilter.completed,
            onTap: () => onChanged(_OrderFilter.completed),
          ),
          _FilterChip(
            label: "Cancelled",
            selected: value == _OrderFilter.cancelled,
            onTap: () => onChanged(_OrderFilter.cancelled),
          ),
          _FilterChip(
            label: "Pending",
            selected: value == _OrderFilter.pending,
            onTap: () => onChanged(_OrderFilter.pending),
          ),
        ].expand((w) => [w, const SizedBox(width: 8)]).toList()..removeLast(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primaryGreen : Colors.white;
    final fg = selected ? Colors.white : AppColors.textPrimary;
    final border = selected
        ? AppColors.primaryGreen.withOpacity(0.35)
        : AppColors.borderLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            boxShadow: [
              if (!selected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.dateText,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
    required this.leadingColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String priceText;
  final String dateText;

  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final Color leadingColor;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeadingIcon(color: leadingColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StatusPill(
                            text: statusLabel,
                            fg: statusFg,
                            bg: statusBg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.payments_rounded,
                            text: priceText,
                          ),
                          const SizedBox(width: 10),
                          _InfoChip(
                            icon: Icons.calendar_month_rounded,
                            text: dateText,
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.black.withOpacity(0.22),
                          ),
                        ],
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

class _LeadingIcon extends StatelessWidget {
  final Color color;
  const _LeadingIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.shopping_bag_rounded, color: color),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const _StatusPill({required this.text, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black.withOpacity(0.65)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _InlineHint extends StatelessWidget {
  const _InlineHint({
    required this.icon,
    required this.text,
    required this.actionText,
    required this.onAction,
  });

  final IconData icon;
  final String text;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black.withOpacity(0.55)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
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
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: Colors.black.withOpacity(0.7)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textTertiary,
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
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
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

class _StatusMeta {
  final String label;
  final Color dot;
  final Color bg;
  final Color fg;

  const _StatusMeta({
    required this.label,
    required this.dot,
    required this.bg,
    required this.fg,
  });
}
