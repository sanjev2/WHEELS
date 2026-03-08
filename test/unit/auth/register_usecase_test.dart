import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wheels_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:wheels_flutter/features/auth/domain/usecases/signup_usecases.dart';

import '../../test_utils/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late RegisterUsecase usecase;

  setUpAll(registerTestFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: repository);
  });

  test('maps params to AuthEntity and calls register', () async {
    when(() => repository.register(any())).thenAnswer((_) async => const Right(true));

    await usecase(const RegisterParams(
      name: 'Test',
      email: 'test@test.com',
      password: '123456',
      confirmPassword: '123456',
      contact: '9800',
      address: 'KTM',
    ));

    final captured = verify(() => repository.register(captureAny())).captured.single as AuthEntity;
    expect(captured.name, 'Test');
    expect(captured.role, 'user');
    expect(captured.isLoggedIn, false);
  });
}
