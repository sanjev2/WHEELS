// features/auth/data/datasources/local/auth_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:wheels_flutter/core/constants/hive_constants.dart';
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

  AuthHiveModel? _getLoggedInUser() {
    try {
      return _userBox.values.firstWhere((user) => user.isLoggedIn);
    } catch (_) {
      return null;
    }
  }

  AuthHiveModel _copyWithLoginState(
    AuthHiveModel user, {
    required bool isLoggedIn,
  }) {
    return AuthHiveModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      contact: user.contact,
      address: user.address,
      password: user.password,
      isLoggedIn: isLoggedIn,
      createdAt: user.createdAt,
    );
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final matchedUsers = _userBox.values.where(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );

      if (matchedUsers.isEmpty) return null;

      // Logout all users first
      for (final u in _userBox.values) {
        await _userBox.put(u.userId, _copyWithLoginState(u, isLoggedIn: false));
      }

      final user = matchedUsers.first;
      final loggedInUser = _copyWithLoginState(user, isLoggedIn: true);

      await _userBox.put(user.userId, loggedInUser);

      // Save session
      await _userSessionService.saveUserSession(
        userId: user.userId,
        email: user.email,
        name: user.name,
        contact: user.contact,
        address: user.address,
      );

      return loggedInUser;
    } catch (e) {
      print('Local login error: $e');
      return null;
    }
  }

  @override
  Future<AuthHiveModel> signup(AuthHiveModel user) async {
    try {
      final emailExists = _userBox.values.any(
        (u) => u.email.toLowerCase() == user.email.toLowerCase(),
      );

      if (emailExists) {
        throw Exception('User already exists with this email');
      }

      // Logout all existing users
      for (final u in _userBox.values) {
        await _userBox.put(u.userId, _copyWithLoginState(u, isLoggedIn: false));
      }

      final newUser = _copyWithLoginState(user, isLoggedIn: true);

      await _userBox.put(newUser.userId, newUser);

      // Save session
      await _userSessionService.saveUserSession(
        userId: newUser.userId,
        email: newUser.email,
        name: newUser.name,
        contact: newUser.contact,
        address: newUser.address,
      );

      return newUser;
    } catch (e) {
      print('Local signup error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final currentUser = _getLoggedInUser();
      if (currentUser == null) return;

      await _userBox.put(
        currentUser.userId,
        _copyWithLoginState(currentUser, isLoggedIn: false),
      );

      await _userSessionService.clearSession();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      return _getLoggedInUser();
    } catch (e) {
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
}
