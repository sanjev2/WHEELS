import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/error/failure.dart';
import 'package:wheels_flutter/core/services/biometric/biometric_credential_store.dart';
import 'package:wheels_flutter/core/services/biometric/biometric_service.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';

import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/repositories/auth_repositories.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/get_current_users.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/is_login_usecase.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';

import 'package:wheels_flutter/features/booking/presentation/model/booking_draft.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockIsLoggedInUsecase extends Mock implements IsLoggedInUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockApiClient extends Mock implements ApiClient {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockBiometricSecureStore extends Mock implements BiometricSecureStore {}

class MockBiometricService extends Mock implements BiometricService {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

class FakeAuthEntity extends Fake implements AuthEntity {}

class FakeOptions extends Fake implements Options {}

class FakeFormData extends Fake implements FormData {}

class FakeBookingDraft extends Fake implements BookingDraft {}

void registerTestFallbacks() {
  registerFallbackValue(FakeLoginParams());
  registerFallbackValue(FakeRegisterParams());
  registerFallbackValue(FakeAuthEntity());
  registerFallbackValue(FakeOptions());
  registerFallbackValue(FakeFormData());
  registerFallbackValue(FakeBookingDraft());
}

void registerAuthFakes() => registerTestFallbacks();

AuthEntity makeAuthEntity({
  String? userId = 'u1',
  String name = 'Test User',
  String email = 'test@example.com',
  String? password = '123456',
  String? confirmPassword = '123456',
  String contact = '9800000000',
  String address = 'Kathmandu',
  bool isLoggedIn = true,
  String role = 'user',
  String? profilePicture,
}) {
  return AuthEntity(
    userId: userId,
    name: name,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
    contact: contact,
    address: address,
    isLoggedIn: isLoggedIn,
    role: role,
    profilePicture: profilePicture,
  );
}

Failure makeFailure([String message = 'Something went wrong']) =>
    AuthFailure(message: message);
