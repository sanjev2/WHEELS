import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/order/data/respositories/order_repositories.impl.dart';
import 'package:wheels_flutter/features/order/domain/usecases/get_order_usecase.dart';
import '../state/order_state.dart';

final getMyOrdersUsecaseProvider = Provider<GetMyOrdersUsecase>((ref) {
  return GetMyOrdersUsecase(repo: ref.read(orderRepositoryProvider));
});

final ordersViewModelProvider =
    StateNotifierProvider<OrdersViewModel, OrdersState>((ref) {
      return OrdersViewModel(usecase: ref.read(getMyOrdersUsecaseProvider));
    });

class OrdersViewModel extends StateNotifier<OrdersState> {
  final GetMyOrdersUsecase usecase;

  OrdersViewModel({required this.usecase}) : super(OrdersState.initial());

  Future<void> loadMyOrders() async {
    state = state.copyWith(status: OrderStatusUi.loading, errorMessage: null);

    final res = await usecase();
    res.fold(
      (l) => state = state.copyWith(
        status: OrderStatusUi.error,
        errorMessage: l.message,
      ),
      (r) => state = state.copyWith(status: OrderStatusUi.loaded, orders: r),
    );
  }
}
