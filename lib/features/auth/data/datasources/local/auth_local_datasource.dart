import 'package:hive/hive.dart';
import 'package:wheels_flutter/core/constants/hive_constants.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

class AuthLocalDatasource implements IAuthDatasource {
  Box<AuthHiveModel> get _userBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  AuthHiveModel? _getLoggedInUser() {
    try {
      return _userBox.values.firstWhere((user) => user.isLoggedIn);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final users = _userBox.values
          .where((user) => user.email == email && user.password == password)
          .toList();

      if (users.isEmpty) return null;

      // Set all users to logged out first
      final allUsers = _userBox.values.toList();
      for (final u in allUsers) {
        await _userBox.put(
          u.userId,
          AuthHiveModel(
            userId: u.userId,
            fullName: u.fullName,
            email: u.email,
            phoneNumber: u.phoneNumber,
            address: u.address,
            username: u.username,
            password: u.password,
            isLoggedIn: false,
            createdAt: u.createdAt,
          ),
        );
      }

      final user = users.first;
      final loggedInUser = AuthHiveModel(
        userId: user.userId,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        address: user.address,
        username: user.username,
        password: user.password,
        isLoggedIn: true,
        createdAt: user.createdAt,
      );

      await _userBox.put(user.userId, loggedInUser);
      return loggedInUser;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  @override
  Future<AuthHiveModel> signup(AuthHiveModel user) async {
    try {
      // Check if user already exists with this email
      final existing = _userBox.values
          .where((u) => u.email == user.email)
          .toList();

      if (existing.isNotEmpty) {
        throw Exception('User already exists with this email');
      }

      // Check if username already exists
      final existingUsername = _userBox.values
          .where((u) => u.username == user.username)
          .toList();

      if (existingUsername.isNotEmpty) {
        throw Exception('Username already taken');
      }

      // Create new user with logged-in status
      final newUser = AuthHiveModel(
        userId: user.userId,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        address: user.address,
        username: user.username,
        password: user.password,
        isLoggedIn: true,
        createdAt: user.createdAt,
      );

      await _userBox.put(newUser.userId, newUser);
      print('✅ User created: ${newUser.email}');
      return newUser;
    } catch (e) {
      print('Signup error: $e');
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
        AuthHiveModel(
          userId: currentUser.userId,
          fullName: currentUser.fullName,
          email: currentUser.email,
          phoneNumber: currentUser.phoneNumber,
          address: currentUser.address,
          username: currentUser.username,
          password: currentUser.password,
          isLoggedIn: false,
          createdAt: currentUser.createdAt,
        ),
      );
      print('✅ User logged out');
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
      return _userBox.values.any((user) => user.isLoggedIn);
    } catch (_) {
      return false;
    }
  }

  // Additional helper methods

  Future<List<AuthHiveModel>> getAllUsers() async {
    try {
      return _userBox.values.toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userBox.delete(userId);
      print('✅ User deleted: $userId');
    } catch (e) {
      print('Delete user error: $e');
    }
  }

  Future<void> updateUser(AuthHiveModel user) async {
    try {
      await _userBox.put(user.userId, user);
      print('✅ User updated: ${user.email}');
    } catch (e) {
      print('Update user error: $e');
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return _userBox.values.any((user) => user.email == email);
    } catch (_) {
      return false;
    }
  }

  // Clear all users (for testing)
  Future<void> clearAllUsers() async {
    try {
      await _userBox.clear();
      print('✅ All users cleared');
    } catch (e) {
      print('Clear users error: $e');
    }
  }
}
