import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/order/data/datasource/remote_datasource.dart';
import 'package:wheels_flutter/features/order/data/model/order_api_model.dart';
import 'package:wheels_flutter/features/order/data/respositories/order_repositories.impl.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';

class MockOrderRemoteDatasource extends Mock
    implements IOrderRemoteDatasource {}

OrderApiModel makeOrderModel({String id = 'o1', String status = 'PAID'}) {
  return OrderApiModel(
    id: id,
    packageTitle: 'Premium Wash',
    category: 'SUV',
    providerName: 'Garage A',
    totalPrice: 2500,
    status: status,
    createdAt: DateTime.parse('2025-01-10T10:00:00.000Z'),
    paidAt: null,
    transactionUuid: null,
    transactionCode: null,
  );
}

void main() {
  late MockOrderRemoteDatasource remote;
  late OrderRepositoryImpl repo;

  setUp(() {
    remote = MockOrderRemoteDatasource();
    repo = OrderRepositoryImpl(remote: remote);
  });

  test('returns mapped entities on success', () async {
    when(
      () => remote.getMyOrders(),
    ).thenAnswer((_) async => [makeOrderModel()]);

    final result = await repo.getMyOrders();

    expect(result.isRight(), true);
    final list = result.getOrElse(() => <OrderEntity>[]);
    expect(list.length, 1);
    expect(list.first.id, 'o1');
  });

  test('returns ApiFailure on exception', () async {
    when(() => remote.getMyOrders()).thenThrow(Exception('Boom'));

    final result = await repo.getMyOrders();

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, contains('Boom')),
      (_) => fail('Expected failure'),
    );
  });
}
