import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/api/api_endpoints.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';
import 'package:wheels_flutter/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

abstract class IAuthRemoteDatasource {
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel> register(AuthApiModel user);
  Future<void> logout();
}

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.Login,
      data: {"email": email, "password": password},
    );

    if (response.data["success"] == true) {
      final data = response.data["data"];
      final token = response.data["token"];

      final user = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.authId!,
        email: user.email,
        name: user.name,
        contact: user.contact,
        address: user.address,
      );

      await _secureStorage.write(key: "auth_token", value: token);
      return user;
    }
    return null;
  }

  // Update this part in your existing auth_remote_datasource.dart
  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.Register,
        data: user.toJson(),
      );

      if (response.data["success"] == true) {
        return AuthApiModel.fromJson(response.data["data"]);
      }

      // Get error message from response
      final errorMessage =
          response.data["message"] ??
          response.data["error"] ??
          "Registration failed";

      throw Exception(errorMessage);
    } on DioException catch (e) {
      // Handle Dio errors
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        final errorMessage =
            errorData["message"] ??
            errorData["error"] ??
            e.message ??
            "Registration failed";
        throw Exception(errorMessage);
      }
      throw Exception(e.message ?? "Network error during registration");
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: "auth_token");
    await _userSessionService.clearSession();
  }
}
