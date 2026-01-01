import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:wheels_flutter/core/constants/hive_constants.dart';
import '../../domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final String username;

  @HiveField(6)
  final String? password;

  @HiveField(7)
  final bool isLoggedIn;

  @HiveField(8)
  final DateTime createdAt;

  AuthHiveModel({
    String? userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.username,
    this.password,
    this.isLoggedIn = false,
    DateTime? createdAt,
  }) : userId = userId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Convert Model to Auth Entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      username: username,
      password: password,
      isLoggedIn: isLoggedIn,
    );
  }

  // Convert Auth Entity to Model
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      username: entity.username,
      password: entity.password,
      isLoggedIn: entity.isLoggedIn,
    );
  }
}
