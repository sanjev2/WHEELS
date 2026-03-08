import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/order/data/datasource/remote_datasource.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import 'package:wheels_flutter/features/order/domain/repositories/order_repositories.dart';

import '../../../../core/error/failure.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  return OrderRepositoryImpl(remote: ref.read(orderRemoteDatasourceProvider));
});

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDatasource remote;
  OrderRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    try {
      final models = await remote.getMyOrders();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
