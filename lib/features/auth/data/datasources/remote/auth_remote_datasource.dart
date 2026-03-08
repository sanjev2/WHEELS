import 'dart:io';

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

  Future<AuthApiModel> getMe();
  Future<String> uploadProfilePicture(File file);

  Future<AuthApiModel> updateProfile({
    required String userId,
    required String name,
    required String contact,
    required String address,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<int> forgotPassword({required String email});
  Future<String> verifyResetCode({required String email, required String code});
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = "auth_token";

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  Future<String?> _getToken() async => _secureStorage.read(key: _tokenKey);

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  String? _extractToken(Map<String, dynamic> root) {
    final t1 = root["token"]?.toString();
    if (t1 != null && t1.isNotEmpty) return t1;

    final data = _asMap(root["data"]);
    final t2 = data?["token"]?.toString();
    if (t2 != null && t2.isNotEmpty) return t2;

    final t3 = root["accessToken"]?.toString();
    if (t3 != null && t3.isNotEmpty) return t3;

    final t4 = data?["accessToken"]?.toString();
    if (t4 != null && t4.isNotEmpty) return t4;

    return null;
  }

  Map<String, dynamic>? _extractUserJson(Map<String, dynamic> root) {
    final u1 = _asMap(root["user"]);
    if (u1 != null) return u1;

    final data = _asMap(root["data"]);
    final u2 = _asMap(data?["user"]);
    if (u2 != null) return u2;

    if (data != null &&
        (data.containsKey("email") || data.containsKey("_id"))) {
      return data;
    }
    return null;
  }

  String _extractMessage(
    Map<String, dynamic> root, {
    String fallback = "Request failed",
  }) {
    return (root["message"] ?? root["error"] ?? fallback).toString();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.Login,
        data: {"email": email.toLowerCase().trim(), "password": password},
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (!success) {
        throw Exception(_extractMessage(root, fallback: "Login failed"));
      }

      final token = _extractToken(root);
      if (token == null || token.isEmpty) {
        throw Exception("Login succeeded but token is missing in response");
      }

      final userJson = _extractUserJson(root);
      if (userJson == null) {
        throw Exception("Login succeeded but user data is missing in response");
      }

      final user = AuthApiModel.fromJson(Map<String, dynamic>.from(userJson));

      await _userSessionService.saveUserSession(
        userId: user.authId ?? userJson["_id"]?.toString() ?? "",
        email: user.email,
        name: user.name,
        contact: user.contact,
        address: user.address,
      );

      if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
        await _userSessionService.saveProfilePicture(user.profilePicture!);
      }

      await _secureStorage.write(key: _tokenKey, value: token);

      return user;
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(errorData, fallback: e.message ?? "Login failed"),
        );
      }
      throw Exception(e.message ?? "Network error during login");
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.Register,
        data: user.toJson(),
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (!success) {
        throw Exception(_extractMessage(root, fallback: "Registration failed"));
      }

      final userJson =
          _extractUserJson(root) ??
          _asMap(root["data"]) ??
          _asMap(root["user"]);
      if (userJson == null) {
        throw Exception("Registration succeeded but no user returned");
      }

      final created = AuthApiModel.fromJson(
        Map<String, dynamic>.from(userJson),
      );

      await _userSessionService.saveUserSession(
        userId: created.authId ?? userJson["_id"]?.toString() ?? "",
        email: created.email,
        name: created.name,
        contact: created.contact,
        address: created.address,
      );

      if (created.profilePicture != null &&
          created.profilePicture!.isNotEmpty) {
        await _userSessionService.saveProfilePicture(created.profilePicture!);
      }

      final token = _extractToken(root);
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: token);
      }

      return created;
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(
            errorData,
            fallback: e.message ?? "Registration failed",
          ),
        );
      }
      throw Exception(e.message ?? "Network error during registration");
    }
  }

  @override
  Future<AuthApiModel> getMe() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token missing. Please login again.");
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.Me,
        option: Options(extra: {"requiresAuth": true}),
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (!success) {
        throw Exception(
          _extractMessage(root, fallback: "Failed to fetch profile"),
        );
      }

      final userJson = _extractUserJson(root) ?? _asMap(root["data"]);
      if (userJson == null) throw Exception("No user returned");

      final me = AuthApiModel.fromJson(Map<String, dynamic>.from(userJson));

      await _userSessionService.saveUserSession(
        userId: me.authId ?? userJson["_id"]?.toString() ?? "",
        email: me.email,
        name: me.name,
        contact: me.contact,
        address: me.address,
      );

      if (me.profilePicture != null && me.profilePicture!.isNotEmpty) {
        await _userSessionService.saveProfilePicture(me.profilePicture!);
      }

      return me;
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(
            errorData,
            fallback: e.message ?? "Failed to fetch profile",
          ),
        );
      }
      throw Exception(e.message ?? "Network error during profile fetch");
    }
  }

  @override
  Future<AuthApiModel> updateProfile({
    required String userId,
    required String name,
    required String contact,
    required String address,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token missing. Please login again.");
    }

    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateUser(userId),
        data: {
          "name": name.trim(),
          "contact": contact.trim(),
          "address": address.trim(),
        },
        option: Options(extra: {"requiresAuth": true}),
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (!success) {
        throw Exception(
          _extractMessage(root, fallback: "Failed to update profile"),
        );
      }

      final userJson = _extractUserJson(root) ?? _asMap(root["data"]);
      if (userJson == null) {
        throw Exception("Update succeeded but user missing");
      }

      final updated = AuthApiModel.fromJson(
        Map<String, dynamic>.from(userJson),
      );

      await _userSessionService.saveUserSession(
        userId: updated.authId ?? userId,
        email: updated.email,
        name: updated.name,
        contact: updated.contact,
        address: updated.address,
      );

      if (updated.profilePicture != null &&
          updated.profilePicture!.isNotEmpty) {
        await _userSessionService.saveProfilePicture(updated.profilePicture!);
      }

      return updated;
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(
            errorData,
            fallback: e.message ?? "Failed to update profile",
          ),
        );
      }
      throw Exception(e.message ?? "Network error during update profile");
    }
  }

  @override
  Future<String> uploadProfilePicture(File file) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token missing. Please login again.");
    }

    try {
      final formData = FormData.fromMap({
        "profilePicture": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.UploadProfilePicture,
        data: formData,
        option: Options(
          contentType: "multipart/form-data",
          extra: {"requiresAuth": true},
        ),
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (!success) {
        throw Exception(_extractMessage(root, fallback: "Upload failed"));
      }

      final data = _asMap(root["data"]) ?? <String, dynamic>{};
      final filename = data["filename"]?.toString();
      if (filename == null || filename.isEmpty) {
        throw Exception("Upload succeeded but filename missing");
      }

      await _userSessionService.saveProfilePicture(filename);

      final userJson = _asMap(data["user"]);
      if (userJson != null) {
        final updated = AuthApiModel.fromJson(
          Map<String, dynamic>.from(userJson),
        );
        await _userSessionService.saveUserSession(
          userId: updated.authId ?? userJson["_id"]?.toString() ?? "",
          email: updated.email,
          name: updated.name,
          contact: updated.contact,
          address: updated.address,
        );
      }

      return filename;
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(errorData, fallback: e.message ?? "Upload failed"),
        );
      }
      throw Exception(e.message ?? "Network error during upload");
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token missing. Please login again.");
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.ChangePassword,
        data: {"currentPassword": currentPassword, "newPassword": newPassword},
        option: Options(extra: {"requiresAuth": true}),
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (success) return;

      throw Exception(
        _extractMessage(root, fallback: "Failed to update password"),
      );
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(
            errorData,
            fallback: e.message ?? "Failed to update password",
          ),
        );
      }
      throw Exception(e.message ?? "Network error during update password");
    }
  }

  @override
  Future<int> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.ForgotPassword,
        data: {"email": email.trim().toLowerCase()},
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (!success) {
        throw Exception(
          _extractMessage(root, fallback: "Failed to send reset code"),
        );
      }

      final data = _asMap(root["data"]) ?? <String, dynamic>{};
      final raw =
          root["cooldownSeconds"] ??
          data["cooldownSeconds"] ??
          data["cooldown"] ??
          root["cooldown"];
      final cooldown = int.tryParse(raw?.toString() ?? "");
      return cooldown ?? 60;
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(
            errorData,
            fallback: e.message ?? "Failed to send reset code",
          ),
        );
      }
      throw Exception(e.message ?? "Network error during forgot password");
    }
  }

  @override
  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.VerifyResetCode,
        data: {"email": email.trim().toLowerCase(), "code": code.trim()},
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (!success) {
        throw Exception(_extractMessage(root, fallback: "Invalid code"));
      }

      final data = _asMap(root["data"]) ?? <String, dynamic>{};
      final token = (data["resetToken"] ?? root["resetToken"])?.toString();
      if (token == null || token.isEmpty) {
        throw Exception("Reset token missing from server response");
      }
      return token;
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(errorData, fallback: e.message ?? "Invalid code"),
        );
      }
      throw Exception(e.message ?? "Network error during verify code");
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.ResetPassword,
        data: {"resetToken": resetToken, "newPassword": newPassword},
      );

      final root = _asMap(response.data) ?? <String, dynamic>{};

      final success =
          root["success"] == true ||
          root["status"] == true ||
          root["ok"] == true;

      if (success) return;

      throw Exception(
        _extractMessage(root, fallback: "Failed to reset password"),
      );
    } on DioException catch (e) {
      final errorData = _asMap(e.response?.data);
      if (errorData != null) {
        throw Exception(
          _extractMessage(
            errorData,
            fallback: e.message ?? "Failed to reset password",
          ),
        );
      }
      throw Exception(e.message ?? "Network error during reset password");
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _userSessionService.clearSession();
  }
}
