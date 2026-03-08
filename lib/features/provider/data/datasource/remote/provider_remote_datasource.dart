import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/api/api_endpoints.dart';
import 'package:wheels_flutter/features/provider/data/model/provider_api_model.dart';

final providerRemoteDatasourceProvider = Provider<ProviderRemoteDatasource>((
  ref,
) {
  return ProviderRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ProviderRemoteDatasource {
  final ApiClient _apiClient;

  ProviderRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<List<ProviderApiModel>> getProviders({
    required String category,
  }) async {
    final Response res = await _apiClient.get(
      ApiEndpoints.PublicProviders,
      queryParameters: {"category": category},
    );

    if (res.data is Map && res.data["success"] == true) {
      final list = res.data["data"] as List<dynamic>;
      return list
          .map((e) => ProviderApiModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception(res.data["message"] ?? "Failed to load providers");
  }
}
