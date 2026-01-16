// features/auth/data/models/auth_api_model.dart

import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String name;
  final String email;
  final String contact;
  final String address;
  final String? password;
  final String? confirmPassword;
  final String role;

  AuthApiModel({
    this.authId,
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    this.password,
    this.confirmPassword,
    this.role = "user", // ✅ DEFAULT ROLE
  });

  /// -------------------------------------------------------------------------
  /// SEND TO BACKEND (FIXES BOTH ERRORS)
  /// -------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      "name": name.trim(),
      "email": email.toLowerCase().trim(),
      "contact": contact.trim(),
      "address": address.trim(),
      "password": password?.trim(),
      "confirmPassword": confirmPassword?.trim(), // ✅ REQUIRED
      "role": role, // ✅ REQUIRED ("user")
    };
  }

  /// -------------------------------------------------------------------------
  /// RECEIVE FROM BACKEND
  /// -------------------------------------------------------------------------
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json["_id"]?.toString(),
      name: json["name"],
      email: json["email"],
      contact: json["contact"],
      address: json["address"],
      role: json["role"] ?? "user",
    );
  }

  /// -------------------------------------------------------------------------
  /// MAP TO ENTITY
  /// -------------------------------------------------------------------------
  AuthEntity toEntity() {
    return AuthEntity(
      userId: authId,
      name: name,
      email: email,
      password: password,
      contact: contact,
      address: address,
      role: role,
      isLoggedIn: false,
    );
  }

  /// -------------------------------------------------------------------------
  /// MAP FROM ENTITY
  /// -------------------------------------------------------------------------
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.userId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword, // ✅ PASS THROUGH
      contact: entity.contact,
      address: entity.address,
      role: entity.role, // ✅ ALWAYS "user"
    );
  }
}
