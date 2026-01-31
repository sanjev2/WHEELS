import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';

import 'package:wheels_flutter/features/auth/domain/usecases/login_usecases.dart'
    show LoginParams;
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart'
    show RegisterParams;

/// Mock Usecases
class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

/// Fakes so mocktail can match params
class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

void registerAuthFakes() {
  registerFallbackValue(FakeLoginParams());
  registerFallbackValue(FakeRegisterParams());
}
