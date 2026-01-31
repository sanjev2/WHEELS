// features/auth/data/models/auth_api_model.dart
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;

  // ✅ backend fields
  final String name;
  final String email;
  final String contact;
  final String address;
  final String role;

  // ✅ backend optional (after you add it): profile_picture
  final String? profilePicture;

  // ✅ only for sending (register/login)
  final String? password;
  final String? confirmPassword; // if your backend requires it; else keep null

  AuthApiModel({
    this.authId,
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    this.role = "user",
    this.profilePicture,
    this.password,
    this.confirmPassword,
  });

  /// ✅ SEND TO BACKEND (REGISTER)
  /// Sends ONLY fields backend accepts.
  Map<String, dynamic> toJson() {
    return {
      "name": name.trim(),
      "email": email.toLowerCase().trim(),
      "contact": contact.trim(),
      "address": address.trim(),
      if (password != null && password!.isNotEmpty) "password": password,
      // Only include confirmPassword if your backend DTO checks it
      if (confirmPassword != null && confirmPassword!.isNotEmpty)
        "confirmPassword": confirmPassword,
      "role": role,
    };
  }

  /// ✅ RECEIVE FROM BACKEND
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: (json["_id"] ?? json["id"] ?? json["authId"])?.toString(),
      name: (json["name"] ?? "").toString(),
      email: (json["email"] ?? "").toString(),
      contact: (json["contact"] ?? "").toString(),
      address: (json["address"] ?? "").toString(),
      role: (json["role"] ?? "user").toString(),
      profilePicture: (json["profile_picture"] ?? json["profilePicture"])
          ?.toString(),
    );
  }

  /// ✅ MAP TO ENTITY (your entity uses same field names)
  AuthEntity toEntity() {
    return AuthEntity(
      userId: authId,
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      contact: contact,
      address: address,
      role: role,
      profilePicture: profilePicture,
      isLoggedIn: false,
    );
  }

  /// ✅ MAP FROM ENTITY
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.userId,
      name: entity.name,
      email: entity.email,
      contact: entity.contact,
      address: entity.address,
      role: entity.role,
      profilePicture: entity.profilePicture,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }
}
