import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/order/data/model/order_api_model.dart';
import '../../../../../core/api/api_clients.dart';
import '../../../../../core/api/api_endpoints.dart';

final orderRemoteDatasourceProvider = Provider<IOrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

abstract class IOrderRemoteDatasource {
  Future<List<OrderApiModel>> getMyOrders();
}

class OrderRemoteDatasource implements IOrderRemoteDatasource {
  final ApiClient _apiClient;
  OrderRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<OrderApiModel>> getMyOrders() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.MyOrders);

      if (res.data is Map && res.data["success"] == true) {
        final list = (res.data["data"] as List?) ?? [];
        return list
            .map((e) => OrderApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw Exception(res.data?["message"] ?? "Failed to load orders");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? e.message ?? "Network error",
      );
    }
  }
}
