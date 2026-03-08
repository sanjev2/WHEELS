import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import 'package:wheels_flutter/features/order/domain/repositories/order_repositories.dart';
import 'package:wheels_flutter/features/order/domain/usecases/get_order_usecase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

OrderEntity makeOrder({
  String id = 'o1',
  String packageTitle = 'Premium Wash',
  String category = 'SUV',
  String providerName = 'Garage A',
  double totalPrice = 2500,
  String status = 'PAID',
}) {
  return OrderEntity(
    id: id,
    packageTitle: packageTitle,
    category: category,
    providerName: providerName,
    totalPrice: totalPrice,
    status: status,
    createdAt: DateTime.parse('2025-01-10T10:00:00.000Z'),
    paidAt: null,
    transactionUuid: null,
    transactionCode: null,
  );
}

void main() {
  late MockOrderRepository repo;
  late GetMyOrdersUsecase usecase;

  setUp(() {
    repo = MockOrderRepository();
    usecase = GetMyOrdersUsecase(repo: repo);
  });

  test('returns orders from repository', () async {
    final orders = [makeOrder()];

    when(() => repo.getMyOrders()).thenAnswer((_) async => Right(orders));

    final result = await usecase();

    expect(result, Right<Failure, List<OrderEntity>>(orders));
    verify(() => repo.getMyOrders()).called(1);
  });

  test('returns failure from repository', () async {
    final failure = ApiFailure(message: 'Failed');

    when(() => repo.getMyOrders()).thenAnswer((_) async => Left(failure));

    final result = await usecase();

    expect(result, Left<Failure, List<OrderEntity>>(failure));
    verify(() => repo.getMyOrders()).called(1);
  });
}
