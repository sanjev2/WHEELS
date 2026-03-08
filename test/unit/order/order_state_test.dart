import 'package:flutter_test/flutter_test.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import 'package:wheels_flutter/features/order/presentation/state/order_state.dart';

OrderEntity makeOrder({String id = 'o1', String status = 'PAID'}) {
  return OrderEntity(
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
  test('initial factory returns initial state', () {
    final state = OrdersState.initial();

    expect(state.status, OrderStatusUi.initial);
    expect(state.orders, isEmpty);
    expect(state.errorMessage, isNull);
  });

  test('copyWith updates values correctly', () {
    final state = OrdersState.initial();

    final updated = state.copyWith(
      status: OrderStatusUi.loaded,
      orders: [makeOrder()],
      errorMessage: 'x',
    );

    expect(updated.status, OrderStatusUi.loaded);
    expect(updated.orders.length, 1);
    expect(updated.errorMessage, 'x');
  });
}
