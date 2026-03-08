import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/api/api_endpoints.dart';
import 'package:wheels_flutter/features/services/data/model/package_api_model.dart';

final servicesRemoteDatasourceProvider = Provider<IServicesRemoteDatasource>((
  ref,
) {
  return ServicesRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

abstract interface class IServicesRemoteDatasource {
  Future<List<PackageApiModel>> getPackages({required String category});
}

class ServicesRemoteDatasource implements IServicesRemoteDatasource {
  final ApiClient _apiClient;

  ServicesRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<PackageApiModel>> getPackages({required String category}) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.PublicPackages,
        queryParameters: {"category": category},
      );

      final data = res.data;
      if (data is Map<String, dynamic> && data["success"] == true) {
        final list = data["data"];
        if (list is List) {
          return list
              .map(
                (e) => PackageApiModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }
      }

      throw Exception("Failed to load packages");
    } on DioException catch (e) {
      throw Exception(e.message ?? "Network error");
    }
  }
}
