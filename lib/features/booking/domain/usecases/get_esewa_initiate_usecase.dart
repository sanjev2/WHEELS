import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import '../../../../core/error/failure.dart';
import '../entities/esewa_initiate_entity.dart';
import '../repositories/booking_repository.dart';

class InitiateEsewaUsecase {
  final IBookingRepository repo;
  InitiateEsewaUsecase({required this.repo});

  Future<Either<Failure, EsewaInitiateEntity>> call(BookingDraft draft) {
    return repo.initiateEsewa(draft);
  }
}
