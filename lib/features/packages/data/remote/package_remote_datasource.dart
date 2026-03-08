import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/services/data/model/package_api_model.dart';
import '../../../../core/api/api_clients.dart';
import '../../../../core/api/api_endpoints.dart';

final packageRemoteDatasourceProvider = Provider<PackageRemoteDatasource>((
  ref,
) {
  return PackageRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class PackageRemoteDatasource {
  final ApiClient _apiClient;

  PackageRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<List<PackageApiModel>> getPackages({required String category}) async {
    final Response res = await _apiClient.get(
      ApiEndpoints.PublicPackages,
      queryParameters: {"category": category},
    );

    if (res.data is Map && res.data["success"] == true) {
      final list = res.data["data"] as List<dynamic>;
      return list
          .map((e) => PackageApiModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception(res.data["message"] ?? "Failed to load packages");
  }
}
