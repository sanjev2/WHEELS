import 'package:dartz/dartz.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import 'package:wheels_flutter/features/order/domain/repositories/order_repositories.dart';
import '../../../../core/error/failure.dart';

class GetMyOrdersUsecase {
  final IOrderRepository repo;
  GetMyOrdersUsecase({required this.repo});

  Future<Either<Failure, List<OrderEntity>>> call() => repo.getMyOrders();
}
