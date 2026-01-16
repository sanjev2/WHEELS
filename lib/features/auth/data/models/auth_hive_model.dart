// features/auth/data/models/auth_hive_model.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/auth_entity.dart';
import 'package:wheels_flutter/core/constants/hive_constants.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String contact;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final bool isLoggedIn;

  @HiveField(7)
  final DateTime createdAt;

  AuthHiveModel({
    String? userId,
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    this.password,
    this.isLoggedIn = false,
    DateTime? createdAt,
  }) : userId = userId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  AuthEntity toEntity() => AuthEntity(
    userId: userId,
    name: name,
    email: email,
    password: password,
    contact: contact,
    address: address,
    isLoggedIn: isLoggedIn,
  );

  factory AuthHiveModel.fromEntity(AuthEntity entity) => AuthHiveModel(
    userId: entity.userId,
    name: entity.name,
    email: entity.email,
    password: entity.password,
    contact: entity.contact,
    address: entity.address,
    isLoggedIn: entity.isLoggedIn,
  );
}
