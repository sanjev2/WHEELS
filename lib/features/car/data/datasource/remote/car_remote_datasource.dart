import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/car_api_model.dart';
import '../../../../../core/api/api_clients.dart';
import '../../../../../core/api/api_endpoints.dart';

final carRemoteDatasourceProvider = Provider<ICarRemoteDatasource>((ref) {
  return CarRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

abstract class ICarRemoteDatasource {
  Future<List<CarApiModel>> getMyCars();
  Future<CarApiModel> addCar(CarApiModel car);
  Future<bool> deleteCar(String id);

  Future<CarApiModel> updateCar(String id, CarApiModel car);
}

class CarRemoteDatasource implements ICarRemoteDatasource {
  final ApiClient _apiClient;
  CarRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CarApiModel>> getMyCars() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.Cars);
      if (res.data["success"] == true) {
        final list = (res.data["data"] as List?) ?? [];
        return list
            .map((e) => CarApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception(res.data["message"] ?? "Failed to load cars");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? e.message ?? "Network error",
      );
    }
  }

  @override
  Future<CarApiModel> addCar(CarApiModel car) async {
    try {
      final res = await _apiClient.post(ApiEndpoints.Cars, data: car.toJson());
      if (res.data["success"] == true) {
        final data = res.data["data"];
        return CarApiModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception(res.data["message"] ?? "Failed to add car");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? e.message ?? "Network error",
      );
    }
  }

  @override
  Future<bool> deleteCar(String id) async {
    try {
      final res = await _apiClient.delete(ApiEndpoints.carById(id));
      if (res.data["success"] == true) return true;
      throw Exception(res.data["message"] ?? "Failed to delete car");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? e.message ?? "Network error",
      );
    }
  }

  @override
  Future<CarApiModel> updateCar(String id, CarApiModel car) async {
    try {
      final res = await _apiClient.put(
        ApiEndpoints.carById(id),
        data: car.toJson(),
      );

      if (res.data["success"] == true) {
        final data = res.data["data"];
        return CarApiModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception(res.data["message"] ?? "Failed to update car");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? e.message ?? "Network error",
      );
    }
  }
}
