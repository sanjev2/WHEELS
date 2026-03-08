import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/features/order/domain/entities/order_entities.dart';
import 'package:wheels_flutter/features/order/domain/usecases/get_order_usecase.dart';
import 'package:wheels_flutter/features/order/presentation/provider/order_provider.dart';
import 'package:wheels_flutter/features/order/presentation/state/order_state.dart';

class MockGetMyOrdersUsecase extends Mock implements GetMyOrdersUsecase {}

OrderEntity makeOrder({
  String id = 'o1',
  String status = 'PAID',
  String packageTitle = 'Premium Wash',
}) {
  return OrderEntity(
    id: id,
    packageTitle: packageTitle,
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
  late MockGetMyOrdersUsecase usecase;
  late OrdersViewModel viewModel;

  setUp(() {
    usecase = MockGetMyOrdersUsecase();
    viewModel = OrdersViewModel(usecase: usecase);
  });

  test('initial state is correct', () {
    expect(viewModel.state.status, OrderStatusUi.initial);
    expect(viewModel.state.orders, isEmpty);
  });

  test('loadMyOrders sets loaded state on success', () async {
    when(() => usecase()).thenAnswer((_) async => Right([makeOrder()]));

    await viewModel.loadMyOrders();

    expect(viewModel.state.status, OrderStatusUi.loaded);
    expect(viewModel.state.orders.length, 1);
    expect(viewModel.state.errorMessage, isNull);
  });

  test('loadMyOrders sets error state on failure', () async {
    when(
      () => usecase(),
    ).thenAnswer((_) async => Left(ApiFailure(message: 'Network error')));

    await viewModel.loadMyOrders();

    expect(viewModel.state.status, OrderStatusUi.error);
    expect(viewModel.state.errorMessage, 'Network error');
  });
}
