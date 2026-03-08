import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/booking/data/remote/esewa_remote_datasource.dart';
import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/esewa_initiate_entity.dart';
import '../../domain/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  return BookingRepositoryImpl(remote: ref.read(esewaRemoteDatasourceProvider));
});

class BookingRepositoryImpl implements IBookingRepository {
  final EsewaRemoteDatasource _remote;

  BookingRepositoryImpl({required EsewaRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, EsewaInitiateEntity>> initiateEsewa(
    BookingDraft draft,
  ) async {
    try {
      final data = await _remote.initiateEsewaPayment(draft);
      return Right(data);
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.message ?? "Network error"));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
