import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/booking/domain/usecases/get_esewa_initiate_usecase.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import '../state/booking_state.dart';

class BookingViewModel extends StateNotifier<BookingState> {
  final InitiateEsewaUsecase _initiateEsewa;

  BookingViewModel({required InitiateEsewaUsecase initiateEsewa})
    : _initiateEsewa = initiateEsewa,
      super(const BookingState());

  void startDraft(BookingDraft draft) {
    state = state.copyWith(
      status: BookingStatus.selecting,
      draft: draft,
      errorMessage: null,
      esewa: null,
    );
  }

  void setOilType(String oil) {
    final d = state.draft;
    if (d == null) return;
    state = state.copyWith(draft: d.copyWith(selectedOilType: oil));
  }

  void setAddons(List<String> addons) {
    final d = state.draft;
    if (d == null) return;
    state = state.copyWith(draft: d.copyWith(selectedAddons: addons));
  }

  void setProvider({required String providerId, required String providerName}) {
    final d = state.draft;
    if (d == null) return;
    state = state.copyWith(
      draft: d.copyWith(providerId: providerId, providerName: providerName),
      status: BookingStatus.ready,
    );
  }

  Future<void> payWithEsewa() async {
    final d = state.draft;
    if (d == null || d.providerId == null || d.providerName == null) {
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: "Please select provider first.",
      );
      return;
    }

    state = state.copyWith(status: BookingStatus.loading, errorMessage: null);

    final result = await _initiateEsewa(d);
    result.fold(
      (failure) => state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: failure.message,
      ),
      (esewa) =>
          state = state.copyWith(status: BookingStatus.initiated, esewa: esewa),
    );
  }
}
