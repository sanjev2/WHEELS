import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';

enum OrderStatusUi { initial, loading, loaded, error }

class OrdersState {
  final OrderStatusUi status;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const OrdersState({
    required this.status,
    required this.orders,
    this.errorMessage,
  });

  factory OrdersState.initial() =>
      const OrdersState(status: OrderStatusUi.initial, orders: []);

  OrdersState copyWith({
    OrderStatusUi? status,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }
}
