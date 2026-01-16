// features/auth/data/datasources/auth_datasource.dart
import 'package:wheels_flutter/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDatasource {
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel> signup(AuthHiveModel user);
  Future<void> logout();
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> isUserLoggedIn();
}
