import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import '../../../../core/error/failure.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
}
