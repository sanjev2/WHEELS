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

  // ✅ needed for profile screen
  Future<AuthApiModel> getMe();

  // ✅ profile picture upload
  Future<String> uploadProfilePicture(File file);
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

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.Login,
        data: {"email": email.toLowerCase().trim(), "password": password},
      );

      if (response.data["success"] == true) {
        final token = response.data["token"]?.toString();

        // ✅ your backend may return: { user: {...}, token } OR { data: {...}, token }
        final userJson = response.data["user"] ?? response.data["data"];
        if (userJson == null) {
          throw Exception("Login succeeded but user data missing");
        }

        final user = AuthApiModel.fromJson(Map<String, dynamic>.from(userJson));

        // ✅ Save session for profile screen (matches your session fields)
        await _userSessionService.saveUserSession(
          userId: user.authId ?? "",
          email: user.email,
          name: user.name,
          contact: user.contact,
          address: user.address,
        );

        // ✅ Save profile picture filename if exists
        // (Only works after you add saveProfilePicture() to UserSessionService)
        if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
          await _userSessionService.saveProfilePicture(user.profilePicture!);
        }

        if (token == null || token.isEmpty) {
          throw Exception("Token missing in login response");
        }
        await _secureStorage.write(key: _tokenKey, value: token);

        return user;
      }

      throw Exception(
        response.data["message"] ?? response.data["error"] ?? "Login failed",
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw Exception(
          errorData["message"] ??
              errorData["error"] ??
              e.message ??
              "Login failed",
        );
      }
      throw Exception(e.message ?? "Network error during login");
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.Register, // /auth/signup
        data: user
            .toJson(), // ✅ sends only name/email/contact/address/password/role
      );

      if (response.data["success"] == true) {
        final userJson = response.data["data"] ?? response.data["user"];
        if (userJson == null) {
          throw Exception("Registration successful but no user returned");
        }

        final created = AuthApiModel.fromJson(
          Map<String, dynamic>.from(userJson),
        );

        // ✅ Optional: store user details right away (you can keep this)
        await _userSessionService.saveUserSession(
          userId: created.authId ?? "",
          email: created.email,
          name: created.name,
          contact: created.contact,
          address: created.address,
        );

        if (created.profilePicture != null &&
            created.profilePicture!.isNotEmpty) {
          await _userSessionService.saveProfilePicture(created.profilePicture!);
        }

        return created;
      }

      throw Exception(
        response.data["message"] ??
            response.data["error"] ??
            "Registration failed",
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw Exception(
          errorData["message"] ??
              errorData["error"] ??
              e.message ??
              "Registration failed",
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
      final response = await _apiClient.get(ApiEndpoints.Me);

      if (response.data["success"] == true) {
        final userJson = response.data["data"] ?? response.data["user"];
        if (userJson == null) throw Exception("No user returned");

        final me = AuthApiModel.fromJson(Map<String, dynamic>.from(userJson));

        // ✅ refresh local session
        await _userSessionService.saveUserSession(
          userId: me.authId ?? "",
          email: me.email,
          name: me.name,
          contact: me.contact,
          address: me.address,
        );

        if (me.profilePicture != null && me.profilePicture!.isNotEmpty) {
          await _userSessionService.saveProfilePicture(me.profilePicture!);
        }

        return me;
      }

      throw Exception(response.data["message"] ?? "Failed to fetch profile");
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw Exception(
          errorData["message"] ?? e.message ?? "Failed to fetch profile",
        );
      }
      throw Exception(e.message ?? "Network error during profile fetch");
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
        // ✅ MUST match multer: uploadProfilePicture.single("profilePicture")
        "profilePicture": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.UploadProfilePicture,
        data: formData,
        option: Options(contentType: "multipart/form-data"),
      );

      if (response.data["success"] == true) {
        final data = response.data["data"];
        final filename = data?["filename"]?.toString();

        if (filename == null || filename.isEmpty) {
          throw Exception("Upload succeeded but filename missing");
        }

        // ✅ save filename to session
        await _userSessionService.saveProfilePicture(filename);

        // ✅ if backend returns updated user, refresh session too
        final userJson = data?["user"];
        if (userJson != null) {
          final updated = AuthApiModel.fromJson(
            Map<String, dynamic>.from(userJson),
          );

          await _userSessionService.saveUserSession(
            userId: updated.authId ?? "",
            email: updated.email,
            name: updated.name,
            contact: updated.contact,
            address: updated.address,
          );

          if (updated.profilePicture != null &&
              updated.profilePicture!.isNotEmpty) {
            await _userSessionService.saveProfilePicture(
              updated.profilePicture!,
            );
          }
        }

        return filename;
      }

      throw Exception(response.data["message"] ?? "Upload failed");
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw Exception(errorData["message"] ?? e.message ?? "Upload failed");
      }
      throw Exception(e.message ?? "Network error during upload");
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _userSessionService.clearSession();
  }
}
