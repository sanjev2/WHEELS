// features/auth/data/models/auth_api_model.dart
import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String name;
  final String email;
  final String contact;
  final String address;
  final String role;

  final String? profilePicture;
  final String? password;
  final String? confirmPassword;

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

  Map<String, dynamic> toJson() {
    return {
      "name": name.trim(),
      "email": email.toLowerCase().trim(),
      "contact": contact.trim(),
      "address": address.trim(),
      if (password != null && password!.isNotEmpty) "password": password,
      if (confirmPassword != null && confirmPassword!.isNotEmpty)
        "confirmPassword": confirmPassword,
      "role": role,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    final dynamic userObj = json["user"];

    String? id = (json["_id"] ?? json["id"] ?? json["authId"])?.toString();

    if ((id == null || id.isEmpty) && userObj is Map) {
      id = (userObj["_id"] ?? userObj["id"] ?? userObj["userId"])?.toString();
    }

    return AuthApiModel(
      authId: id,
      name: (json["name"] ?? (userObj is Map ? userObj["name"] : "") ?? "")
          .toString(),
      email: (json["email"] ?? (userObj is Map ? userObj["email"] : "") ?? "")
          .toString(),
      contact:
          (json["contact"] ?? (userObj is Map ? userObj["contact"] : "") ?? "")
              .toString(),
      address:
          (json["address"] ?? (userObj is Map ? userObj["address"] : "") ?? "")
              .toString(),
      role:
          (json["role"] ??
                  (userObj is Map ? userObj["role"] : "user") ??
                  "user")
              .toString(),
      profilePicture:
          (json["profile_picture"] ??
                  json["profilePicture"] ??
                  (userObj is Map ? userObj["profile_picture"] : null))
              ?.toString(),
    );
  }

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
      isLoggedIn: true,
    );
  }

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
