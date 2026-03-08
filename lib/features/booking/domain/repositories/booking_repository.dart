import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import '../../../../core/error/failure.dart';
import '../entities/esewa_initiate_entity.dart';

abstract interface class IBookingRepository {
  Future<Either<Failure, EsewaInitiateEntity>> initiateEsewa(
    BookingDraft draft,
  );
}
