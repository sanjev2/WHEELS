// features/auth/domain/entities/auth_entity.dart
import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? password;
  final String? confirmPassword; // Make sure this field exists
  final String contact;
  final String address;
  final bool isLoggedIn;
  final String role;
  

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.password,
    this.confirmPassword, // Make sure constructor has this parameter
    required this.contact,
    required this.address,
    this.isLoggedIn = false,
    this.role = "user",
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
  ];
}
