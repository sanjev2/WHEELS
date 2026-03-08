import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/booking/data/repositories/booking.repositories_impl.dart';
import 'package:wheels_flutter/features/booking/domain/usecases/get_esewa_initiate_usecase.dart';
import 'package:wheels_flutter/features/booking/presentation/state/booking_state.dart';
import 'package:wheels_flutter/features/booking/presentation/view%20model/booking_view_model.dart';

final initiateEsewaUsecaseProvider = Provider<InitiateEsewaUsecase>((ref) {
  return InitiateEsewaUsecase(repo: ref.read(bookingRepositoryProvider));
});

final bookingViewModelProvider =
    StateNotifierProvider<BookingViewModel, BookingState>((ref) {
      return BookingViewModel(
        initiateEsewa: ref.read(initiateEsewaUsecaseProvider),
      );
    });
