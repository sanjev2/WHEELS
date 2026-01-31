// features/auth/domain/entities/auth_entity.dart
import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String contact;
  final String address;
  final bool isLoggedIn;
  final String role;

  // ✅ ADD ONLY THIS
  final String? profilePicture; // filename from backend: profile_picture

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.password,
    this.confirmPassword,
    required this.contact,
    required this.address,
    this.isLoggedIn = false,
    this.role = "user",
    this.profilePicture,
  });

  AuthEntity copyWith({
    String? userId,
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? contact,
    String? address,
    bool? isLoggedIn,
    String? role,
    String? profilePicture,
  }) {
    return AuthEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    password,
    confirmPassword,
    contact,
    address,
    isLoggedIn,
    role,
    profilePicture, // ✅ ADD
  ];
}
