import 'package:equatable/equatable.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import '../../domain/entities/esewa_initiate_entity.dart';

enum BookingStatus { initial, selecting, ready, loading, initiated, error }

class BookingState extends Equatable {
  final BookingStatus status;
  final BookingDraft? draft;
  final EsewaInitiateEntity? esewa;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.initial,
    this.draft,
    this.esewa,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    BookingDraft? draft,
    EsewaInitiateEntity? esewa,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      draft: draft ?? this.draft,
      esewa: esewa ?? this.esewa,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, draft, esewa, errorMessage];
}
