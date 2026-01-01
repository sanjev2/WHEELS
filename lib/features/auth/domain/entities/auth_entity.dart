import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String username;
  final String? password;
  final String? profilePicture;
  final bool isLoggedIn;

  const AuthEntity({
    this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.username,
    this.password,
    this.profilePicture,
    this.isLoggedIn = false,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    phoneNumber,
    address,
    username,
    password,
    profilePicture,
    isLoggedIn,
  ];
}
