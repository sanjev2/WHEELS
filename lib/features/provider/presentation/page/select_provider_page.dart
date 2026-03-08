import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/booking/presentation/page/esewa_webview_page.dart';
import 'package:wheels_flutter/features/booking/presentation/providers/booking_provoder.dart';
import 'package:wheels_flutter/features/provider/presentation/providers/provider_provider.dart';
import '../../../booking/presentation/state/booking_state.dart';
import '../state/provider_state.dart';

class ProviderSelectPage extends ConsumerStatefulWidget {
  final String category;

  const ProviderSelectPage({super.key, required this.category});

  @override
  ConsumerState<ProviderSelectPage> createState() => _ProviderSelectPageState();
}

class _ProviderSelectPageState extends ConsumerState<ProviderSelectPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(providerViewModelProvider.notifier)
          .loadProviders(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final providersState = ref.watch(providerViewModelProvider);
    final bookingState = ref.watch(bookingViewModelProvider);

    ref.listen<BookingState>(bookingViewModelProvider, (prev, next) {
      if (!context.mounted) return;

      if (next.status == BookingStatus.initiated && next.esewa != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EsewaWebViewPage(esewa: next.esewa!),
          ),
        );
      }

      if (next.status == BookingStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final selectedProviderId = bookingState.draft?.providerId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "Select Provider",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.maybePop(context),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF0B1220),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: _body(context, providersState, selectedProviderId),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.black.withOpacity(0.12),
              ),
              onPressed:
                  (bookingState.status == BookingStatus.loading ||
                      selectedProviderId == null)
                  ? null
                  : () async {
                      await ref
                          .read(bookingViewModelProvider.notifier)
                          .payWithEsewa();
                    },
              child: bookingState.status == BookingStatus.loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.payments_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Pay with eSewa",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ProviderState state, String? selectedId) {
    if (state.status == ProviderStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ProviderStatus.error) {
      return Center(child: Text(state.errorMessage ?? "Error"));
    }

    final list = state.providers;
    if (list.isEmpty) {
      return const Center(child: Text("No providers found"));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = list[i];
        final isSelected = selectedId == p.id;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF16A34A).withOpacity(0.4)
                  : Colors.black.withOpacity(0.06),
              width: isSelected ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF16A34A).withOpacity(0.18)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                ref
                    .read(bookingViewModelProvider.notifier)
                    .setProvider(providerId: p.id, providerName: p.name);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Selected: ${p.name}"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF16A34A), Color(0xFF10B981)],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.storefront_outlined,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (p.locationText != null)
                            Text(
                              p.locationText!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            "${p.openFrom} - ${p.openTo}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isSelected
                          ? Container(
                              key: const ValueKey("selected"),
                              height: 28,
                              width: 28,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF16A34A),
                                    Color(0xFF10B981),
                                  ],
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.black38,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
