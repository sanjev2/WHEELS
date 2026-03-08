import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:wheels_flutter/core/constants/hive_constants.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';

import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

final authLocalDatasourceProvider = Provider<IAuthDatasource>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(userSessionService: userSessionService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final UserSessionService _userSessionService;

  AuthLocalDatasource({required UserSessionService userSessionService})
    : _userSessionService = userSessionService;

  Box<AuthHiveModel> get _userBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final matchedUsers = _userBox.values.where(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase().trim() &&
            (u.password ?? "") == password,
      );

      if (matchedUsers.isEmpty) return null;

      final user = matchedUsers.first;

      await _userSessionService.saveUserSession(
        userId: user.userId,
        email: user.email,
        name: user.name,
        contact: user.contact,
        address: user.address,
      );

      return user;
    } catch (e) {
      // ignore: avoid_print
      print('Local login error: $e');
      return null;
    }
  }

  @override
  Future<AuthHiveModel> signup(AuthHiveModel user) async {
    try {
      final emailExists = _userBox.values.any(
        (u) => u.email.toLowerCase() == user.email.toLowerCase().trim(),
      );

      if (emailExists) {
        throw Exception('User already exists with this email');
      }

      await _userBox.put(user.userId, user);

      await _userSessionService.saveUserSession(
        userId: user.userId,
        email: user.email,
        name: user.name,
        contact: user.contact,
        address: user.address,
      );

      return user;
    } catch (e) {
      // ignore: avoid_print
      print('Local signup error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _userSessionService.clearSession();
    } catch (e) {
      // ignore: avoid_print
      print('Logout error: $e');
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) return null;

      final userId = _userSessionService.getUserId();
      if (userId == null || userId.isEmpty) return null;

      // Prefer hive record if exists
      final hiveUser = _userBox.get(userId);
      if (hiveUser != null) return hiveUser;

      // Build from session if not in hive
      return AuthHiveModel(
        userId: userId,
        name: _userSessionService.getName() ?? "",
        email: _userSessionService.getEmail() ?? "",
        contact: _userSessionService.getContact() ?? "",
        address: _userSessionService.getAddress() ?? "",
        password: null,
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Get current user error: $e');
      return null;
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return _userSessionService.isLoggedIn();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> forgotPassword({required String email}) async {
    throw UnimplementedError("Forgot password is not supported locally");
  }

  @override
  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) async {
    throw UnimplementedError("Verify reset code is not supported locally");
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    throw UnimplementedError("Reset password is not supported locally");
  }
}
